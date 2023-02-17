classdef gatfd_ui_network_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        GATFD_network_UIFigure         matlab.ui.Figure
        GridLayout                     matlab.ui.container.GridLayout
        Button_loadfiles               matlab.ui.control.Button
        UIAxes                         matlab.ui.control.UIAxes
        LoadTemporalMaskButton         matlab.ui.control.Button
        CalculateNetworkPropertiesButton  matlab.ui.control.Button
        NetworkAverageGlobalMeasuresPanel  matlab.ui.container.Panel
        GridLayout3                    matlab.ui.container.GridLayout
        GlobalEfficiencyCheckBox       matlab.ui.control.CheckBox
        LocalEfficiencyCheckBox        matlab.ui.control.CheckBox
        ClusteringCoefficientCheckBox  matlab.ui.control.CheckBox
        DegreeCheckBox                 matlab.ui.control.CheckBox
        SmallWorldCoefficientCheckBox  matlab.ui.control.CheckBox
        ModularityCoefficientCheckBox  matlab.ui.control.CheckBox
        NormalizedClusteringCoefficientCheckBox  matlab.ui.control.CheckBox
        NormalizedPathLengthCheckBox   matlab.ui.control.CheckBox
        TransitivityCoefficientCheckBox  matlab.ui.control.CheckBox
        AssortativityCoefficientCheckBox  matlab.ui.control.CheckBox
        CharacteristicPathLengthCheckBox  matlab.ui.control.CheckBox
        NodalMeasuresPanel             matlab.ui.container.Panel
        GridLayout4                    matlab.ui.container.GridLayout
        ListBox                        matlab.ui.control.ListBox
        SelectNodesButton              matlab.ui.control.Button
        NodalGlobalEfficiencyCheckBox  matlab.ui.control.CheckBox
        NodalLocalEfficiencyCheckBox   matlab.ui.control.CheckBox
        NodalClusteringCoefficientCheckBox  matlab.ui.control.CheckBox
        NodalDegreeCheckBox            matlab.ui.control.CheckBox
        BetweennessCentralityCheckBox  matlab.ui.control.CheckBox
        ThresholdingPanel              matlab.ui.container.Panel
        GridLayout2                    matlab.ui.container.GridLayout
        ThresholdLowerEditField        matlab.ui.control.NumericEditField
        ThresholdEditFieldLabel_2      matlab.ui.control.Label
        AbsoluteCheckBox               matlab.ui.control.CheckBox
        ThresholdingMethodDropDownLabel  matlab.ui.control.Label
        ThresholdingMethodDropDown     matlab.ui.control.DropDown
        ThresholdRangeLabel            matlab.ui.control.Label
        ThresholdUpperEditField        matlab.ui.control.NumericEditField
        ThresholdStepLabel             matlab.ui.control.Label
        ThresholdStepEditField         matlab.ui.control.NumericEditField
        ParallelCheckBox               matlab.ui.control.CheckBox
        LoadedFIlesTextAreaLabel       matlab.ui.control.Label
        TextArea_LoadedFiles           matlab.ui.control.TextArea
    end

    
    properties (Access = private)
        gatn_setting % Description
        gatn_measure
    end
    
    methods (Access = private)
        % Dialog for choosing nodes
        function results = choose_node(app)
            d=uifigure("Position",[100 100 292 714],'Name','Select nodes for calculation');
            
            % Create SelectNodesforCalculationListBoxLabel
            SelectNodesforCalculationListBoxLabel = uilabel(d);
            SelectNodesforCalculationListBoxLabel.HorizontalAlignment = 'right';
            SelectNodesforCalculationListBoxLabel.Position = [69 666 156 22];
            SelectNodesforCalculationListBoxLabel.Text = 'Select Nodes for Calculation';

            % Create SelectNodesforCalculationListBox
            SelectNodesforCalculationListBox = uilistbox(d);
            SelectNodesforCalculationListBox.Multiselect = 'on';
            SelectNodesforCalculationListBox.Position = [31 79 231 588];
            SelectNodesforCalculationListBox.Items = app.gatn_setting.node_list;
            SelectNodesforCalculationListBox.Value = {};

            % Create DoneButton
            DoneButton = uibutton(d, 'push',...
                                  'Position',[162 34 100 22],...
                                  'Text','Done',...
                                  'ButtonPushedFcn',@fnc_done);
   
            function fnc_done(src,event)
                app.gatn_setting.node_list_selected=SelectNodesforCalculationListBox.Value;
                app.ListBox.Items = app.gatn_setting.node_list_selected;
                close(d);
            end
        end

        % Network Global Efficiency
        function results = calc_global_efficiency(~,temp_net)
            results = efficiency_bin(temp_net,0);
            return
        end
        
        % Network Local Efficiency
        function results = calc_network_local_efficiency(~,temp_net)
            results = mean(efficiency_bin(temp_net,1));
            return
        end
        
        % Network Clustering Coefficient
        function results = calc_network_clustering_coefficient(~,temp_net)
            results = mean(clustering_coef_bu(temp_net));
            return
        end
        
        % Network Averaged Degree
        function results = calc_network_average_degree(~,temp_net)
            results = mean(degrees_und(temp_net));
            return
        end
                
        % Network characteristic path length
        function results = calc_network_characteristic_path(~,temp_net)
            results = charpath(distance_bin(temp_net),0,0);
            return
        end
        
        % Network SW Normalized CC
        function results = calc_sw_norm_cc(~,temp_net)
            num_edges=round(sum(temp_net(:))/2);
            num_nodes=length(temp_net);
            cc=0;
            for i=1:20
                temp_rand=makerandCIJ_und(num_nodes,num_edges);
                cc=cc+mean(clustering_coef_bu(temp_rand));
            end
            cc=cc/20;
            results = mean(clustering_coef_bu(temp_net))/cc;
            return
        end
        
        % Network SW Normalized Path Length
        function results = calc_sw_norm_pl(~,temp_net)
            num_edges=round(sum(temp_net(:))/2);
            num_nodes=length(temp_net);
            pl=0;
            for i=1:20
                temp_rand=makerandCIJ_und(num_nodes,num_edges);
                pl=pl+charpath(distance_bin(temp_rand),0,0);
            end
            pl=pl/20;
            results = charpath(distance_bin(temp_net),0,0)/pl;
            return
        end
        
        % Network SW Coefficient
        function results = calc_sw_coefficient(~,temp_net)
            num_edges=round(sum(temp_net(:))/2);
            num_nodes=length(temp_net);
            pl=0;
            cc=0;
            for i=1:20
                temp_rand=makerandCIJ_und(num_nodes,num_edges);
                pl=pl+charpath(distance_bin(temp_rand),0,0);
                cc=cc+mean(clustering_coef_bu(temp_rand));
            end
            pl=pl/20;
            cc=cc/20;
            results = (mean(clustering_coef_bu(temp_net))/cc)/(charpath(distance_bin(temp_net),0,0)/pl);
            return
        end
        
        % Network Modularity
        function results = calc_modularity(~,temp_net)
            [~,results]=modularity_und(temp_net);
            return
        end
        
        % Network Transitivity
        function results = calc_transitivity(~,temp_net)
            results = transitivity_bu(temp_net);
            return
        end
        
        % Network Assortativity
        function results = calc_assortativity(~,temp_net)
            results = assortativity_bin(temp_net,0);
            return
        end
        
        % Nodal Global Efficiency / Nodal Efficiency
        function results = calc_nodal_efficiency(~,temp_net)    % From Brain Connectivity Toolbox
            n=length(temp_net);     %number of nodes
            temp_net(1:n+1:end)=0;      %clear diagonal
            temp_net=double(temp_net~=0);       %enforce double precision
            l=1;        %path length
            Lpath=temp_net;     %matrix of paths l
            D=temp_net;     %distance matrix
            n_=length(temp_net);
            
            Idx=true;
            while any(Idx(:))
                l=l+1;
                Lpath=Lpath*temp_net;
                Idx=(Lpath~=0)&(D==0);
                D(Idx)=l;
            end
            
            D(~D | eye(n_))=inf;        %assign inf to disconnected nodes and to diagonal
            D=1./D;     %invert distance
            results=sum(D)./n;
            return
        end
        
        % Nodal Local Efficiency
        function results = calc_nodal_local_efficiency(~,temp_net)
            results = efficiency_bin(temp_net,1);
            return
        end
        
        % Nodal Clustering Coefficient
        function results = calc_nodal_clustering_coefficient(~,temp_net)
            results = clustering_coef_bu(temp_net);
            return
        end
        
        function results = calc_nodal_degree(~,temp_net)
            results = degrees_und(temp_net);
            return
        end
        
        function results = calc_nodal_betweenness(~,temp_net)
            results = betweenness_bin(temp_net);
            return
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % Update UI
            movegui(app.GATFD_network_UIFigure,'southwest');
            app.ThresholdingMethodDropDown.ItemsData = {1,2,3};
            app.NormalizedClusteringCoefficientCheckBox.Text = ['Normalized Clustering Coefficient (',char(947),')'];
            app.NormalizedPathLengthCheckBox.Text = ['Normalized Path Length (',char(955),')'];
            
            % Check if brain connectivity toolbox installed
            prec_bct=exist('degrees_und.m','file');
            if ~(prec_bct==2)
                errordlg('Please check if Brain Connectivity Toolbox is correctly installed','Prerequisite not satisfied');
            end
            
            % Check if nanmax exist
            prec_nm=exist('nanmax.m','file');
            if ~(prec_nm==2)
                temp_path=fileparts(mfilename('fullpath'));
                addpath(fullfile(temp_path,'utility'));
            end

            % Initialize settings
            app.gatn_setting.threshold_lower=0.1;
            app.gatn_setting.threshold_upper=0.4;
            app.gatn_setting.threshold_step=0.02;
            app.gatn_setting.threshold_method=1;  % 0:cost, 1:absolute, 2:relative
            app.gatn_setting.threshold_absolute=0;
            
            app.gatn_setting.parallel=0;
            app.gatn_setting.file_list={};
            app.gatn_setting.file_path_list = [];
            app.gatn_setting.condition = [];
            app.gatn_setting.node_list={};
            app.gatn_setting.node_list_unselected={};
            app.gatn_setting.node_list_selected={};
            app.gatn_setting.iscondition=0;           
            
            % Predefined global/network measures
            app.gatn_measure.glob_name={'global_efficiency','network_local_efficiency','network_clustering_coefficient',...
                                        'network_average_degree', 'characteristic_path_length','small_world_coefficient',...
                                        'normalized_clustering_coefficient','normalized_path_length','transitivity',...
                                        'assortativity','modularity'};
            app.gatn_measure.glob_count=length(app.gatn_measure.glob_name);
            app.gatn_measure.glob_measure=zeros(1,app.gatn_measure.glob_count);         % Measurement flag
            app.gatn_measure.glob_label={'glo_eff','glo_lef','glo_clc','glo_deg','glo_cpl','sw_coef','norm_cc','norm_pl','glo_tra','glo_ast','glo_mod'};
            app.gatn_measure.glob_func={@app.calc_global_efficiency,...
                                        @app.calc_network_local_efficiency,...
                                        @app.calc_network_clustering_coefficient,...
                                        @app.calc_network_average_degree,...
                                        @app.calc_network_characteristic_path,...
                                        @app.calc_sw_coefficient,...
                                        @app.calc_sw_norm_cc,...
                                        @app.calc_sw_norm_pl,...
                                        @app.calc_transitivity,...
                                        @app.calc_assortativity,...
                                        @app.calc_modularity};
            % Predefined nodal measures
            app.gatn_measure.nod_name={'nodal_efficiency','nodal_local_efficiency','nodal_clustering_coefficient','nodal_degree','nodal_betweenness'};
            app.gatn_measure.nod_label={'nod_eff','nod_lef','nod_clc','nod_deg','nod_bet'};
            app.gatn_measure.nod_count=length(app.gatn_measure.nod_name);
            app.gatn_measure.nod_measure=zeros(1,app.gatn_measure.nod_count);
            app.gatn_measure.nod_func={@app.calc_nodal_efficiency,...
                                       @app.calc_nodal_local_efficiency,...
                                       @app.calc_nodal_clustering_coefficient,...
                                       @app.calc_nodal_degree,...
                                       @app.calc_nodal_betweenness};
            
        end

        % Button pushed function: Button_loadfiles
        function gatn_loadfile(app, event)
            [fnc_temp_file,fnc_temp_path] = uigetfile('*.mat','Select One or More Files', 'MultiSelect','on');
            if isequal(fnc_temp_file,0)
                disp('Selection Canceled')
            else
                if ~iscell(fnc_temp_file)
                    fnc_temp_file={fnc_temp_file};
                end
                app.gatn_setting.file_list = fnc_temp_file;
                app.gatn_setting.file_path_list = fnc_temp_path;
                app.TextArea_LoadedFiles.Value = app.gatn_setting.file_list;
                temp_file_path=fullfile(fnc_temp_path,app.gatn_setting.file_list{1});
                temp_feature=load(temp_file_path);
                if isfield(temp_feature.subj_data,'d_atlas_list')
                    app.gatn_setting.node_list=temp_feature.subj_data.d_atlas_list;
                else
                    for i=1:length(temp_feature.subj_data.d_corr(1,:,1))
                        app.gatn_setting.node_list(i)={num2str(i)};
                    end
                end
                app.gatn_setting.node_list_selected=app.gatn_setting.node_list;
                app.ListBox.Items = app.gatn_setting.node_list_selected;
            end
        end

        % Button pushed function: LoadTemporalMaskButton
        function gatn_loadconditions(app, event)
            % This function upload design matrix from file that generated
            % by TrFNC-Design
            [fnc_temp_file,fnc_temp_path,~] = uigetfile('*.mat','Select Conditions');
            if isequal(fnc_temp_file,0)
                app.gatn_setting.iscondition=0;
                return
            else
                file_fullpath=fullfile(fnc_temp_path,fnc_temp_file);
                temp=load(file_fullpath,'window_condition');
                try
                    app.gatn_setting.condition=temp.window_condition.dfnc_window_condi;
                    plot(app.UIAxes,temp.window_condition.dfnc_window_condi);
                    app.gatn_setting.iscondition=1;
                catch
                    errordlg("Please check task design matrix is correct","Error");
                end
            end
        end

        % Button pushed function: CalculateNetworkPropertiesButton
        function gatn_run(app, event)
            % Check if loaded file
            if isempty(app.gatn_setting.file_list)
                errordlg("Please load the input file first","Error");
                return
            end

            % Update Settings
            % Global Measures
            app.gatn_measure.glob_measure(1)=app.GlobalEfficiencyCheckBox.Value;
            app.gatn_measure.glob_measure(2)=app.LocalEfficiencyCheckBox.Value;
            app.gatn_measure.glob_measure(3)=app.ClusteringCoefficientCheckBox.Value;
            app.gatn_measure.glob_measure(4)=app.DegreeCheckBox.Value;
            app.gatn_measure.glob_measure(5)=app.CharacteristicPathLengthCheckBox.Value;
            app.gatn_measure.glob_measure(6)=app.SmallWorldCoefficientCheckBox.Value;
            app.gatn_measure.glob_measure(7)=app.NormalizedClusteringCoefficientCheckBox.Value;
            app.gatn_measure.glob_measure(8)=app.NormalizedPathLengthCheckBox.Value;
            app.gatn_measure.glob_measure(9)=app.TransitivityCoefficientCheckBox.Value;
            app.gatn_measure.glob_measure(10)=app.AssortativityCoefficientCheckBox.Value;
            app.gatn_measure.glob_measure(11)=app.ModularityCoefficientCheckBox.Value;
            meas_glob_list=find(app.gatn_measure.glob_measure);
            run_if_glob=not(isempty(meas_glob_list));
            
            % Nodal Measures
            app.gatn_measure.nod_measure(1)=app.NodalGlobalEfficiencyCheckBox.Value;
            app.gatn_measure.nod_measure(2)=app.NodalLocalEfficiencyCheckBox.Value;
            app.gatn_measure.nod_measure(3)=app.NodalClusteringCoefficientCheckBox.Value;
            app.gatn_measure.nod_measure(4)=app.NodalDegreeCheckBox.Value;
            app.gatn_measure.nod_measure(5)=app.BetweennessCentralityCheckBox.Value;
            meas_nod_list=find(app.gatn_measure.nod_measure);
            run_if_nod=not(isempty(meas_nod_list) || isempty(app.gatn_setting.node_list_selected));
           
            if not(run_if_glob || run_if_nod)
                errordlg("Please select network properties","Error");
                return
            end
            
            [fnc_out_file,fnc_out_path] = uiputfile('*.csv','Select directory to save settings','network_properties.csv');
            if isequal(fnc_out_file,0)
                return
            end
            
            fnc_filelength=length(app.gatn_setting.file_list);
            
            % Initialize process bar
            process_fig = uifigure;
            process_d = uiprogressdlg(process_fig,'Title','Calculating Network');
            
            % ################################
            % # Check if design matches data #
            % ################################

            % Other Settings
            app.gatn_setting.threshold_lower=app.ThresholdLowerEditField.Value;
            app.gatn_setting.threshold_upper=app.ThresholdUpperEditField.Value;
            app.gatn_setting.threshold_step=app.ThresholdStepEditField.Value;
            app.gatn_setting.threshold_method=app.ThresholdingMethodDropDown.Value;  % 0:cost, 1:absolute, 2:relative
            app.gatn_setting.threshold_absolute=app.AbsoluteCheckBox.Value;
            app.gatn_setting.parallel=app.ParallelCheckBox.Value;
            
            % Load number of nodes
            if run_if_nod
                data_num_nodes=length(app.gatn_setting.node_list_selected);
                nodal_idx=zeros(1,data_num_nodes);
                for idx=1:data_num_nodes
                    nodal_idx(idx)=find(contains(app.gatn_setting.node_list,app.gatn_setting.node_list_selected{idx}));
                end
            end
            
            % Load Settings
            fnc_in_file=fullfile(app.gatn_setting.file_path_list,app.gatn_setting.file_list{1});
            temp_sub_data=load(fnc_in_file);
            
            % Check data
            dnet_data_threshold_list=app.gatn_setting.threshold_lower:app.gatn_setting.threshold_step:app.gatn_setting.threshold_upper;
            data_num_thres_steps=length(dnet_data_threshold_list);
            data_window_size=length(temp_sub_data.subj_data.d_corr,1);
            
            if run_if_glob
                dnet_data_measures_glob=app.gatn_measure.glob_name(meas_glob_list);
            else
                dnet_data_measures_glob=[];
            end
            
            if run_if_nod
                dnet_data_nodes_list=app.gatn_setting.node_list_selected;
                dnet_data_measures_nod=app.gatn_measure.nod_name(meas_nod_list);
            else
                dnet_data_nodes_list=[];
                dnet_data_measures_nod=[];
            end
            
            dnet_data_files=app.gatn_setting.file_list;

            if app.gatn_setting.parallel==1 % Parallel Processing
                process_d.Value=0.3;
                process_d.Message = {'Running in parallel'};
                
                % Create Local variable
                local_threshold_absolute=app.gatn_setting.threshold_absolute;
                local_threshold_method=app.gatn_setting.threshold_method;
                
                local_file_path=app.gatn_setting.file_path_list;
                local_file_list=app.gatn_setting.file_list;
                
                if run_if_glob
                    local_glob_func=app.gatn_measure.glob_func;
                    local_glob_count=length(meas_glob_list);
                    local_glob_name=app.gatn_measure.glob_name(meas_glob_list);
                end
                
                if run_if_nod
                    local_nod_func=app.gatn_measure.nod_func;
                    local_nod_count=length(meas_nod_list);
                    local_nod_name=app.gatn_measure.nod_name(meas_nod_list);
                end

                parfor idx_file=1:fnc_filelength              
                    % Load data file
                    fnc_in_file=fullfile(local_file_path,local_file_list{idx_file});
                    temp_mat=matfile(fnc_in_file,'writable',true);
                    temp_subj_data=temp_mat.subj_data;
                    
                    % Data type:  frames * measures * threshold steps * nodes * subjects
                    if run_if_glob
                        network_data_mat_global_para=zeros(data_window_size,local_glob_count,data_num_thres_steps);
                    else
                        network_data_mat_global_para=[];
                    end
                    if run_if_nod
                        network_data_mat_nodal_para=zeros(data_window_size,local_nod_count,data_num_thres_steps,data_num_nodes);
                    else
                        network_data_mat_nodal_para=[];
                    end
                
                    for idx_thr=1:numel(dnet_data_threshold_list)
                        % Update Progress
 
                        for idx_frame=1:data_window_size
                                                    
                            % Thresholding
                            temp_net=squeeze(temp_subj_data.d_corr(idx_frame,:,:));
                            temp_net(isnan(temp_net))=0;
                            
                            %% Absolute
                            if local_threshold_absolute==1
                                temp_net=abs(temp_net);
                            end
                            
                            %% Methods
                            if local_threshold_method==3
                                temp_net_thresh_para=prctile(temp_net(:),(1-dnet_data_threshold_list(idx_thr))*100);
                            elseif  local_threshold_method==2
                                temp_net_thresh_para=max(temp_net(:))*dnet_data_threshold_list(idx_thr);                    
                            else
                                temp_net_thresh_para=dnet_data_threshold_list(idx_thr);
                            end

                            temp_net=threshold_absolute(temp_net,temp_net_thresh_para);
                            temp_net=weight_conversion(temp_net,'binarize');
                            
                            % Calculate Properties
                            % Global
                            if run_if_glob
                                for idx_meas=1:local_glob_count
                                    network_data_mat_global_para(idx_frame,idx_meas,idx_thr)=local_glob_func{meas_glob_list(idx_meas)}(temp_net);
                                end
                            end
                            % Nodal
                            if run_if_nod
                                for idx_meas=1:local_nod_count
                                    temp_prop=local_nod_func{meas_nod_list(idx_meas)}(temp_net);
                                    network_data_mat_nodal_para(idx_frame,idx_meas,idx_thr,:)=temp_prop(nodal_idx);
                                end
                            end
                        end    % End of for-loop (Sliding window)
                    end    % End of for-loop (Threshold list)
                    if run_if_glob
                        temp_mat.network_data_mat_global=network_data_mat_global_para;
                        temp_mat.network_measure_global=local_glob_name;
                    end
                    if run_if_nod
                        temp_mat.network_data_mat_nodal=network_data_mat_nodal_para;
                        temp_mat.network_measure_nodal=local_nod_name;
                    end
                end
                    
            else % Non-parallel
                % Generate Settings
                if run_if_glob
                    local_glob_count=length(meas_glob_list);
                    local_glob_name=app.gatn_measure.glob_name(meas_glob_list);
                end
                if run_if_nod
                    local_nod_count=length(meas_nod_list);
                    local_nod_name=app.gatn_measure.nod_name(meas_nod_list);
                end
                
                for idx_file=1:fnc_filelength
                    % Update progress info
                    process_d.Value=(idx_file-1)/fnc_filelength*0.7;
                    process_d.Message = {[num2str(idx_file),'/',num2str(fnc_filelength),': Calculating Network Properties']};
                    
                    % Load data file
                    fnc_in_file=fullfile(app.gatn_setting.file_path_list,app.gatn_setting.file_list{idx_file});
                    
                    temp_mat=matfile(fnc_in_file,'writable',true);
                    temp_subj_data=temp_mat.subj_data;
                    
                    if run_if_glob
                        network_data_mat_global=zeros(data_window_size,local_glob_count,data_num_thres_steps);
                    end
                    if run_if_nod
                        network_data_mat_nodal=zeros(data_window_size,local_nod_count,data_num_thres_steps,data_num_nodes);
                    end
                        
                    for idx_thr=1:data_num_thres_steps
                        % Update Progress
                        process_d.Value=(idx_file-0.7*(1-(dnet_data_threshold_list(idx_thr)-app.gatn_setting.threshold_lower)/(app.gatn_setting.threshold_upper-app.gatn_setting.threshold_lower)))/fnc_filelength*(7/10);
                        process_d.Message = {[num2str(idx_file),'/',num2str(fnc_filelength),': Calculating Network Properties - Cost:',num2str(dnet_data_threshold_list(idx_thr))]};
                       
                        for idx_frame=1:data_window_size
                            % Thresholding
                            temp_net=squeeze(temp_subj_data.d_corr(idx_frame,:,:));
                            temp_net(isnan(temp_net))=0;
                            
                            %% Absolutecnn
                            if app.gatn_setting.threshold_absolute==1
                                temp_net=abs(temp_net);
                            end
                            %% Methods
                            
                            if app.gatn_setting.threshold_method==3
                                temp_net_thresh_para=prctile(temp_net(:),(1-dnet_data_threshold_list(idx_thr))*100);
                            elseif  app.gatn_setting.threshold_method==2
                                temp_net_thresh_para=max(temp_net(:))*dnet_data_threshold_list(idx_thr);                    
                            else
                                temp_net_thresh_para=dnet_data_threshold_list(idx_thr);
                            end
                            
                            temp_net=threshold_absolute(temp_net,temp_net_thresh_para);
                            temp_net=weight_conversion(temp_net,'binarize');
                            
                            % Calculate Properties
                            % Global
                            if run_if_glob
                                for idx_meas=1:local_glob_count
                                    network_data_mat_global(idx_frame,idx_meas,idx_thr)=app.gatn_measure.glob_func{meas_glob_list(idx_meas)}(temp_net);
                                end
                            end
                            % Nodal
                            if run_if_nod
                                for idx_meas=1:local_nod_count
                                    temp_prop=app.gatn_measure.nod_func{meas_nod_list(idx_meas)}(temp_net);
                                    network_data_mat_nodal(idx_frame,idx_meas,idx_thr,:)=temp_prop(nodal_idx);
                                end
                            end
                        end
                    end
                    if run_if_glob
                        temp_mat.network_data_mat_global=network_data_mat_global;
                        temp_mat.network_measure_global=local_glob_name;
                    end
                    if run_if_nod
                        temp_mat.network_data_mat_nodal=network_data_mat_nodal;
                        temp_mat.network_measure_nodal=local_nod_name;
                    end
                end
            end
            
            
            process_d.Value=0.7;
            process_d.Message = {'Update Data'};
            
            % Write output
            out_path=fullfile(fnc_out_path,fnc_out_file);
            save([out_path,'.mat'],"dnet_data_threshold_list","dnet_data_nodes_list","dnet_data_measures_glob","dnet_data_measures_nod","dnet_data_files",'-v7.3');
            out_mat=matfile([out_path,'.mat'],'writable',true);
            
            if run_if_glob
                out_mat.dnet_data_data_mat_global=zeros(data_window_size,local_glob_count,data_num_thres_steps,fnc_filelength);
            end
            if run_if_nod
                out_mat.dnet_data_data_mat_nodal=zeros(data_window_size,local_nod_count,data_num_thres_steps,data_num_nodes,fnc_filelength);
            end

            % Create output data
            if app.gatn_setting.iscondition==1
                out_data={};
                out_data(1)={'filename'};
                % Thresholding
                if run_if_glob
                    for idx_meas=1:local_glob_count
                        out_data(end+1)={[app.gatn_measure.glob_label{meas_glob_list(idx_meas)},'_var']};
                        out_data(end+1)={[app.gatn_measure.glob_label{meas_glob_list(idx_meas)},'_mean']};
                    end
                end
                if run_if_nod
                    for idx_node=1:data_num_nodes
                        for idx_meas=1:local_nod_count
                            out_data(end+1)={[app.gatn_measure.nod_label{meas_nod_list(idx_meas)},'_',app.gatn_setting.node_list_selected{idx_node},'_var']};
                            out_data(end+1)={[app.gatn_measure.nod_label{meas_nod_list(idx_meas)},'_',app.gatn_setting.node_list_selected{idx_node},'_mean']};
                        end
                    end
                end
                out_data=strrep(out_data,'.','_');
            end    % End of if (condition is loaded)
            
            for idx_file=1:fnc_filelength            % Load data file
                process_d.Value=0.7+0.3*idx_file/fnc_filelength;
                process_d.Message = {[num2str(idx_file),'/',num2str(fnc_filelength),': Update Data']};
                
                fnc_in_file=fullfile(app.gatn_setting.file_path_list,app.gatn_setting.file_list{idx_file});
                temp_mat=matfile(fnc_in_file);
                
                if run_if_glob
                    network_data_mat_global=temp_mat.network_data_mat_global;
                end
                if run_if_nod
                    network_data_mat_nodal=temp_mat.network_data_mat_nodal;
                end
                
                if fnc_filelength==1
                    if run_if_glob
                        out_mat.dnet_data_data_mat_global(:,:,:)=network_data_mat_global;
                    end
                    if run_if_nod
                        out_mat.dnet_data_data_mat_nodal(:,:,:,:)=network_data_mat_nodal;
                    end
                else
                    if run_if_glob
                        out_mat.dnet_data_data_mat_global(:,:,:,idx_file)=network_data_mat_global;
                    end
                    if run_if_nod
                        out_mat.dnet_data_data_mat_nodal(:,:,:,:,idx_file)=network_data_mat_nodal;
                    end
                end
                
                % Write Data
                if app.gatn_setting.iscondition==1      % If condition is loaded
                    out_counter=1;
                    out_data(idx_file+1,out_counter)=app.gatn_setting.file_list(idx_file);
                    out_counter=out_counter+1;
                
                    condit_index=app.gatn_setting.condition==1;
                    if run_if_glob
                        for idx_meas=1:local_glob_count
                            out_data(idx_file+1,out_counter)={mean(var(squeeze(network_data_mat_global(condit_index,idx_meas,:)),0,1))};
                            out_counter=out_counter+1;
                            out_data(idx_file+1,out_counter)={mean(mean(squeeze(network_data_mat_global(condit_index,idx_meas,:)),1))};
                            out_counter=out_counter+1;
                        end
                    end
                    
                    if run_if_nod
                        for idx_node=1:data_num_nodes
                        % Calculate Properties
                            for idx_meas=1:local_nod_count
                                out_data(idx_file+1,out_counter)={mean(var(squeeze(network_data_mat_nodal(condit_index,idx_meas,:,idx_node)),0,1))};
                                out_counter=out_counter+1;
                                out_data(idx_file+1,out_counter)={mean(mean(squeeze(network_data_mat_nodal(condit_index,idx_meas,:,idx_node)),1))};
                                out_counter=out_counter+1;
                            end     % End of for-loop (measure)
                        end    % End of for-loop (nodes)
                    end    % End of if (nod)
                end    % End of if (if condition is loaded)
            end    % End of for-loop (Load files)
            
            if app.gatn_setting.iscondition==1
                data_cell=cell2table(out_data(2:end,:));
                data_cell.Properties.VariableNames=out_data(1,:);
                % Output data
                % Issue: other function if older version
                writetable(data_cell,out_path,'Delimiter','comma');
            end
            
            close(process_d);
            close(process_fig);
            msgbox("Finished");
        end

        % Button pushed function: SelectNodesButton
        function gatn_select_nodes(app, event)
            app.choose_node();
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create GATFD_network_UIFigure and hide until all components are created
            app.GATFD_network_UIFigure = uifigure('Visible', 'off');
            app.GATFD_network_UIFigure.Position = [100 100 650 800];
            app.GATFD_network_UIFigure.Name = 'GAT-FD - Network Property Calculation v0.3a';

            % Create GridLayout
            app.GridLayout = uigridlayout(app.GATFD_network_UIFigure);
            app.GridLayout.ColumnWidth = {20, 71, 27, 73, '1x', 36, 140, 20};
            app.GridLayout.RowHeight = {20, 22, '1x', 22, 135, 135, 160, 22, 20};

            % Create Button_loadfiles
            app.Button_loadfiles = uibutton(app.GridLayout, 'push');
            app.Button_loadfiles.ButtonPushedFcn = createCallbackFcn(app, @gatn_loadfile, true);
            app.Button_loadfiles.Layout.Row = 4;
            app.Button_loadfiles.Layout.Column = [3 4];
            app.Button_loadfiles.Text = 'Load Files';

            % Create UIAxes
            app.UIAxes = uiaxes(app.GridLayout);
            title(app.UIAxes, 'State Conditions')
            xlabel(app.UIAxes, 'Time')
            ylabel(app.UIAxes, 'Condition')
            app.UIAxes.PlotBoxAspectRatio = [2.09126984126984 1 1];
            app.UIAxes.Layout.Row = [2 3];
            app.UIAxes.Layout.Column = [5 7];

            % Create LoadTemporalMaskButton
            app.LoadTemporalMaskButton = uibutton(app.GridLayout, 'push');
            app.LoadTemporalMaskButton.ButtonPushedFcn = createCallbackFcn(app, @gatn_loadconditions, true);
            app.LoadTemporalMaskButton.Layout.Row = 4;
            app.LoadTemporalMaskButton.Layout.Column = 7;
            app.LoadTemporalMaskButton.Text = 'Load Temporal Mask';

            % Create CalculateNetworkPropertiesButton
            app.CalculateNetworkPropertiesButton = uibutton(app.GridLayout, 'push');
            app.CalculateNetworkPropertiesButton.ButtonPushedFcn = createCallbackFcn(app, @gatn_run, true);
            app.CalculateNetworkPropertiesButton.Layout.Row = 8;
            app.CalculateNetworkPropertiesButton.Layout.Column = [6 7];
            app.CalculateNetworkPropertiesButton.Text = 'Calculate Network Properties';

            % Create NetworkAverageGlobalMeasuresPanel
            app.NetworkAverageGlobalMeasuresPanel = uipanel(app.GridLayout);
            app.NetworkAverageGlobalMeasuresPanel.Title = 'Network Average (Global) Measures';
            app.NetworkAverageGlobalMeasuresPanel.Layout.Row = 6;
            app.NetworkAverageGlobalMeasuresPanel.Layout.Column = [2 7];

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.NetworkAverageGlobalMeasuresPanel);
            app.GridLayout3.ColumnWidth = {140, 210, 150};
            app.GridLayout3.RowHeight = {22, 22, 22, 22};
            app.GridLayout3.RowSpacing = 5;
            app.GridLayout3.Padding = [10 5 10 5];

            % Create GlobalEfficiencyCheckBox
            app.GlobalEfficiencyCheckBox = uicheckbox(app.GridLayout3);
            app.GlobalEfficiencyCheckBox.Text = 'Global Efficiency';
            app.GlobalEfficiencyCheckBox.Layout.Row = 1;
            app.GlobalEfficiencyCheckBox.Layout.Column = 1;

            % Create LocalEfficiencyCheckBox
            app.LocalEfficiencyCheckBox = uicheckbox(app.GridLayout3);
            app.LocalEfficiencyCheckBox.Text = 'Local Efficiency';
            app.LocalEfficiencyCheckBox.Layout.Row = 2;
            app.LocalEfficiencyCheckBox.Layout.Column = 1;

            % Create ClusteringCoefficientCheckBox
            app.ClusteringCoefficientCheckBox = uicheckbox(app.GridLayout3);
            app.ClusteringCoefficientCheckBox.Text = 'Clustering Coefficient';
            app.ClusteringCoefficientCheckBox.Layout.Row = 3;
            app.ClusteringCoefficientCheckBox.Layout.Column = 1;

            % Create DegreeCheckBox
            app.DegreeCheckBox = uicheckbox(app.GridLayout3);
            app.DegreeCheckBox.Text = 'Degree';
            app.DegreeCheckBox.Layout.Row = 4;
            app.DegreeCheckBox.Layout.Column = 1;

            % Create SmallWorldCoefficientCheckBox
            app.SmallWorldCoefficientCheckBox = uicheckbox(app.GridLayout3);
            app.SmallWorldCoefficientCheckBox.Text = 'Small World Coefficient';
            app.SmallWorldCoefficientCheckBox.Layout.Row = 2;
            app.SmallWorldCoefficientCheckBox.Layout.Column = 2;

            % Create ModularityCoefficientCheckBox
            app.ModularityCoefficientCheckBox = uicheckbox(app.GridLayout3);
            app.ModularityCoefficientCheckBox.Text = 'Modularity Coefficient';
            app.ModularityCoefficientCheckBox.Layout.Row = 3;
            app.ModularityCoefficientCheckBox.Layout.Column = 3;

            % Create NormalizedClusteringCoefficientCheckBox
            app.NormalizedClusteringCoefficientCheckBox = uicheckbox(app.GridLayout3);
            app.NormalizedClusteringCoefficientCheckBox.Text = 'Normalized Clustering Coefficient ';
            app.NormalizedClusteringCoefficientCheckBox.Layout.Row = 3;
            app.NormalizedClusteringCoefficientCheckBox.Layout.Column = 2;

            % Create NormalizedPathLengthCheckBox
            app.NormalizedPathLengthCheckBox = uicheckbox(app.GridLayout3);
            app.NormalizedPathLengthCheckBox.Text = 'Normalized Path Length';
            app.NormalizedPathLengthCheckBox.Layout.Row = 4;
            app.NormalizedPathLengthCheckBox.Layout.Column = 2;

            % Create TransitivityCoefficientCheckBox
            app.TransitivityCoefficientCheckBox = uicheckbox(app.GridLayout3);
            app.TransitivityCoefficientCheckBox.Text = 'Transitivity Coefficient';
            app.TransitivityCoefficientCheckBox.Layout.Row = 1;
            app.TransitivityCoefficientCheckBox.Layout.Column = 3;

            % Create AssortativityCoefficientCheckBox
            app.AssortativityCoefficientCheckBox = uicheckbox(app.GridLayout3);
            app.AssortativityCoefficientCheckBox.Text = 'Assortativity Coefficient';
            app.AssortativityCoefficientCheckBox.Layout.Row = 2;
            app.AssortativityCoefficientCheckBox.Layout.Column = 3;

            % Create CharacteristicPathLengthCheckBox
            app.CharacteristicPathLengthCheckBox = uicheckbox(app.GridLayout3);
            app.CharacteristicPathLengthCheckBox.Text = 'Characteristic Path Length';
            app.CharacteristicPathLengthCheckBox.Layout.Row = 1;
            app.CharacteristicPathLengthCheckBox.Layout.Column = 2;

            % Create NodalMeasuresPanel
            app.NodalMeasuresPanel = uipanel(app.GridLayout);
            app.NodalMeasuresPanel.Title = 'Nodal Measures';
            app.NodalMeasuresPanel.Layout.Row = 7;
            app.NodalMeasuresPanel.Layout.Column = [2 7];

            % Create GridLayout4
            app.GridLayout4 = uigridlayout(app.NodalMeasuresPanel);
            app.GridLayout4.ColumnWidth = {150, '1x', 200};
            app.GridLayout4.RowHeight = {22, 22, 22, 22, 22};
            app.GridLayout4.RowSpacing = 5;
            app.GridLayout4.Padding = [10 5 10 5];

            % Create ListBox
            app.ListBox = uilistbox(app.GridLayout4);
            app.ListBox.Items = {'Selected Nodes'};
            app.ListBox.Layout.Row = [2 5];
            app.ListBox.Layout.Column = [1 2];
            app.ListBox.Value = 'Selected Nodes';

            % Create SelectNodesButton
            app.SelectNodesButton = uibutton(app.GridLayout4, 'push');
            app.SelectNodesButton.ButtonPushedFcn = createCallbackFcn(app, @gatn_select_nodes, true);
            app.SelectNodesButton.Tooltip = {'Select Nodes for nodal network properties calculation.'};
            app.SelectNodesButton.Layout.Row = 1;
            app.SelectNodesButton.Layout.Column = 1;
            app.SelectNodesButton.Text = 'Select Nodes';

            % Create NodalGlobalEfficiencyCheckBox
            app.NodalGlobalEfficiencyCheckBox = uicheckbox(app.GridLayout4);
            app.NodalGlobalEfficiencyCheckBox.Text = 'Global Efficiency';
            app.NodalGlobalEfficiencyCheckBox.Layout.Row = 1;
            app.NodalGlobalEfficiencyCheckBox.Layout.Column = 3;

            % Create NodalLocalEfficiencyCheckBox
            app.NodalLocalEfficiencyCheckBox = uicheckbox(app.GridLayout4);
            app.NodalLocalEfficiencyCheckBox.Text = 'Local Efficiency';
            app.NodalLocalEfficiencyCheckBox.Layout.Row = 2;
            app.NodalLocalEfficiencyCheckBox.Layout.Column = 3;

            % Create NodalClusteringCoefficientCheckBox
            app.NodalClusteringCoefficientCheckBox = uicheckbox(app.GridLayout4);
            app.NodalClusteringCoefficientCheckBox.Text = 'Clustering Coefficient';
            app.NodalClusteringCoefficientCheckBox.Layout.Row = 3;
            app.NodalClusteringCoefficientCheckBox.Layout.Column = 3;

            % Create NodalDegreeCheckBox
            app.NodalDegreeCheckBox = uicheckbox(app.GridLayout4);
            app.NodalDegreeCheckBox.Text = 'Degree';
            app.NodalDegreeCheckBox.Layout.Row = 4;
            app.NodalDegreeCheckBox.Layout.Column = 3;

            % Create BetweennessCentralityCheckBox
            app.BetweennessCentralityCheckBox = uicheckbox(app.GridLayout4);
            app.BetweennessCentralityCheckBox.Text = 'Betweenness Centrality';
            app.BetweennessCentralityCheckBox.Layout.Row = 5;
            app.BetweennessCentralityCheckBox.Layout.Column = 3;

            % Create ThresholdingPanel
            app.ThresholdingPanel = uipanel(app.GridLayout);
            app.ThresholdingPanel.Title = 'Thresholding';
            app.ThresholdingPanel.Layout.Row = 5;
            app.ThresholdingPanel.Layout.Column = [2 7];

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.ThresholdingPanel);
            app.GridLayout2.ColumnWidth = {150, '1x', 100, 20, 100};
            app.GridLayout2.RowHeight = {22, 22, 22, 22};
            app.GridLayout2.RowSpacing = 5;
            app.GridLayout2.Padding = [10 5 10 5];

            % Create ThresholdLowerEditField
            app.ThresholdLowerEditField = uieditfield(app.GridLayout2, 'numeric');
            app.ThresholdLowerEditField.Layout.Row = 2;
            app.ThresholdLowerEditField.Layout.Column = 3;
            app.ThresholdLowerEditField.Value = 0.1;

            % Create ThresholdEditFieldLabel_2
            app.ThresholdEditFieldLabel_2 = uilabel(app.GridLayout2);
            app.ThresholdEditFieldLabel_2.HorizontalAlignment = 'center';
            app.ThresholdEditFieldLabel_2.Layout.Row = 2;
            app.ThresholdEditFieldLabel_2.Layout.Column = 4;
            app.ThresholdEditFieldLabel_2.Text = '-';

            % Create AbsoluteCheckBox
            app.AbsoluteCheckBox = uicheckbox(app.GridLayout2);
            app.AbsoluteCheckBox.Text = 'Use absolute value of correlation coefficient';
            app.AbsoluteCheckBox.Layout.Row = 4;
            app.AbsoluteCheckBox.Layout.Column = [1 2];

            % Create ThresholdingMethodDropDownLabel
            app.ThresholdingMethodDropDownLabel = uilabel(app.GridLayout2);
            app.ThresholdingMethodDropDownLabel.Layout.Row = 1;
            app.ThresholdingMethodDropDownLabel.Layout.Column = 1;
            app.ThresholdingMethodDropDownLabel.Text = 'Thresholding Method';

            % Create ThresholdingMethodDropDown
            app.ThresholdingMethodDropDown = uidropdown(app.GridLayout2);
            app.ThresholdingMethodDropDown.Items = {'Absolute', 'Proportional', 'Cost'};
            app.ThresholdingMethodDropDown.Layout.Row = 1;
            app.ThresholdingMethodDropDown.Layout.Column = [3 5];
            app.ThresholdingMethodDropDown.Value = 'Cost';

            % Create ThresholdRangeLabel
            app.ThresholdRangeLabel = uilabel(app.GridLayout2);
            app.ThresholdRangeLabel.Layout.Row = 2;
            app.ThresholdRangeLabel.Layout.Column = 1;
            app.ThresholdRangeLabel.Text = 'Threshold Range';

            % Create ThresholdUpperEditField
            app.ThresholdUpperEditField = uieditfield(app.GridLayout2, 'numeric');
            app.ThresholdUpperEditField.Layout.Row = 2;
            app.ThresholdUpperEditField.Layout.Column = 5;
            app.ThresholdUpperEditField.Value = 0.4;

            % Create ThresholdStepLabel
            app.ThresholdStepLabel = uilabel(app.GridLayout2);
            app.ThresholdStepLabel.Layout.Row = 3;
            app.ThresholdStepLabel.Layout.Column = 1;
            app.ThresholdStepLabel.Text = 'Threshold Step';

            % Create ThresholdStepEditField
            app.ThresholdStepEditField = uieditfield(app.GridLayout2, 'numeric');
            app.ThresholdStepEditField.Layout.Row = 3;
            app.ThresholdStepEditField.Layout.Column = 5;
            app.ThresholdStepEditField.Value = 0.02;

            % Create ParallelCheckBox
            app.ParallelCheckBox = uicheckbox(app.GridLayout);
            app.ParallelCheckBox.Text = 'Run in parallel';
            app.ParallelCheckBox.Layout.Row = 8;
            app.ParallelCheckBox.Layout.Column = [2 3];

            % Create LoadedFIlesTextAreaLabel
            app.LoadedFIlesTextAreaLabel = uilabel(app.GridLayout);
            app.LoadedFIlesTextAreaLabel.Layout.Row = 2;
            app.LoadedFIlesTextAreaLabel.Layout.Column = [2 3];
            app.LoadedFIlesTextAreaLabel.Text = 'Loaded FIles';

            % Create TextArea_LoadedFiles
            app.TextArea_LoadedFiles = uitextarea(app.GridLayout);
            app.TextArea_LoadedFiles.Editable = 'off';
            app.TextArea_LoadedFiles.Layout.Row = 3;
            app.TextArea_LoadedFiles.Layout.Column = [2 4];
            app.TextArea_LoadedFiles.Value = {'Loaded Files'};

            % Show the figure after all components are created
            app.GATFD_network_UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = gatfd_ui_network_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.GATFD_network_UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.GATFD_network_UIFigure)
        end
    end
end