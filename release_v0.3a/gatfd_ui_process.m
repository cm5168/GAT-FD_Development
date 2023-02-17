classdef gatfd_ui_process_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        GATFD_process_UIFigure       matlab.ui.Figure
        GridLayout                   matlab.ui.container.GridLayout
        Button_loadfiles             matlab.ui.control.Button
        Button_Default               matlab.ui.control.Button
        Button_AddAtlas              matlab.ui.control.Button
        Button_LoadSetting           matlab.ui.control.Button
        SaveSettingsButton           matlab.ui.control.Button
        RunButton                    matlab.ui.control.Button
        ListBox_Atlas                matlab.ui.control.ListBox
        WindowSizeTRLabel            matlab.ui.control.Label
        EditField_windowsize         matlab.ui.control.NumericEditField
        StepSizeTRLabel              matlab.ui.control.Label
        EditField_stepsize           matlab.ui.control.NumericEditField
        WindowKernelDropDownLabel    matlab.ui.control.Label
        WindowKernelDropDown         matlab.ui.control.DropDown
        AtlasDropDownLabel           matlab.ui.control.Label
        AtlasDropDown                matlab.ui.control.DropDown
        LoadedFIlesLabel             matlab.ui.control.Label
        ListBox_Files                matlab.ui.control.ListBox
        sigmaEditFieldLabel          matlab.ui.control.Label
        sigmaEditField               matlab.ui.control.NumericEditField
        FileFormatDropDownLabel      matlab.ui.control.Label
        FileFormatDropDown           matlab.ui.control.DropDown
        FilterDropDownLabel          matlab.ui.control.Label
        FilterDropDown               matlab.ui.control.DropDown
        Filter_label2Label           matlab.ui.control.Label
        FilterEditField2             matlab.ui.control.EditField
        Filter_label1EditFieldLabel  matlab.ui.control.Label
        FilterEditField1             matlab.ui.control.EditField
        TRsEditFieldLabel            matlab.ui.control.Label
        TRsEditField                 matlab.ui.control.NumericEditField
        AnalysisDropDownLabel        matlab.ui.control.Label
        AnalysisDropDown             matlab.ui.control.DropDown
    end

    
    properties (Access = private)
        gatp_setting
    end    % End of Parameters
    
    methods (Access = private)
        % Reset default value. (This only update the parameters not the field)
        function parameters_default(app)
            % Basic
            app.gatp_setting.file_type = 1;
            app.gatp_setting.file_list = {};
            app.gatp_setting.file_path = {};
            app.gatp_setting.atlas_type = 1;
            app.gatp_setting.atlas_list = importdata(fullfile(app.gatp_setting.path,'atlas','BN_atlas_1_25mm.nii.txt'));
            app.gatp_setting.atlas_path = {};

            % Sliding Window
            app.gatp_setting.tr = 1;
            app.gatp_setting.window_size = 20;
            app.gatp_setting.step_size = 1;
            
            % Filter
            app.gatp_setting.filter_type = 1;
            app.gatp_setting.filter_setting1 = '';
            app.gatp_setting.filter_setting2 = '';
            
            % Kernel
            app.gatp_setting.kernel = 1;
            app.gatp_setting.kernel_setting = 1;
            
            return
        end
        
        % Update parameters from field
        function parameters_update_setting(app)
            % Basic
            %% This function do not update file and atlas list.
            
            % Sliding Window
            app.gatp_setting.tr = app.TRsEditField.Value;
            app.gatp_setting.window_size = app.EditField_windowsize.Value;
            app.gatp_setting.step_size = app.EditField_stepsize.Value;
            
            % Filter
            app.gatp_setting.filter_type = app.FilterDropDown.Value;
            app.gatp_setting.filter_setting1 = app.FilterEditField1.Value;
            app.gatp_setting.filter_setting2 = app.FilterEditField2.Value;
            
            % Kernel
            app.gatp_setting.kernel = app.WindowKernelDropDown.Value;
            app.gatp_setting.kernel_setting=app.sigmaEditField.Value;
            
            return
        end
        
        % Update field from parameters
        function parameters_update_field(app)
            % Basic
            app.FileFormatDropDown.Value = app.gatp_setting.file_type;
            app.ListBox_Files.Items = app.gatp_setting.file_list;
            app.AtlasDropDown.Value = app.gatp_setting.atlas_type;
            app.ListBox_Atlas.Items = app.gatp_setting.atlas_list;
            
            % Sliding Window
            app.TRsEditField.Value = app.gatp_setting.tr;
            app.EditField_windowsize.Value = app.gatp_setting.window_size;
            app.EditField_stepsize.Value = app.gatp_setting.step_size;
            
            % Filter
            app.FilterDropDown.Value = app.gatp_setting.filter_type;
            app.FilterEditField1.Value = app.gatp_setting.filter_setting1;
            app.FilterEditField2.Value = app.gatp_setting.filter_setting2;
            
            % Kernel
            app.WindowKernelDropDown.Value = app.gatp_setting.kernel;
            app.sigmaEditField.Value = app.gatp_setting.kernel_setting;
        end
        
        % Gaussian Kernel Function
        function result=gauss_kernel(app,g_x,g_m,g_s)
            result=exp(-(((g_x-g_m).^2)/(2*g_s.^2)));
            return
        end
    end     % End of Method
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % Update GUI
            % Move to the upper-left corner
            movegui(app.GATFD_process_UIFigure,'northwest');
            % Get APP path
            app.gatp_setting.path=fileparts(mfilename('fullpath'));
            % Update load file dropdown
            app.FileFormatDropDown.ItemsData = [1,2];
            % Update atlas
            app.AtlasDropDown.ItemsData = [1,2,0];
            app.gatp_setting.atlas_list = importdata(fullfile(app.gatp_setting.path,'atlas','BN_atlas_1_25mm.nii.txt'));
            app.ListBox_Atlas.Items = app.gatp_setting.atlas_list;
            % Update filter
            app.FilterDropDown.ItemsData = [1,2,3,4,5];
            app.Filter_label2Label.Text = 'Filter Option';
            app.Filter_label1EditFieldLabel.Text = 'Filter Option';
            % Update kernel
            app.WindowKernelDropDown.ItemsData = [1,2];
            app.sigmaEditFieldLabel.Text=char(963);
            
            % Initializing Parameters
            app.parameters_default();
            app.parameters_update_field;

        end

        % Value changed function: FileFormatDropDown
        function gatp_file_type(app, event)
            app.gatp_setting.file_type = app.FileFormatDropDown.Value;
            switch app.gatp_setting.file_type
                case 1     % If inputs are images
                    app.AtlasDropDownLabel.Enable = 'on';
                    app.AtlasDropDown.Enable = 'on';
                    app.ListBox_Atlas.Enable = 'off';
                    app.Button_AddAtlas.Enable = 'off';
                    app.Button_AddAtlas.Text = 'Add Masks';
                    app.AtlasDropDown.Value=1;
                    app.gatp_setting.atlas_list = importdata(fullfile(app.gatp_setting.path,'atlas','BN_atlas_1_25mm.nii.txt'));
                    app.ListBox_Atlas.Items = app.gatp_setting.atlas_list;
                    app.gatp_setting.file_list = {};
                    app.gatp_setting.file_path_list = {};
                    app.ListBox_Files.Items = app.gatp_setting.file_list;
                case 2      % If inputs are matrices
                    app.AtlasDropDownLabel.Enable = 'off';
                    app.AtlasDropDown.Enable = 'off';
                    app.ListBox_Atlas.Enable = 'on';
                    app.Button_AddAtlas.Enable = 'on';
                    app.Button_AddAtlas.Text = 'Add Labels';
                    app.gatp_setting.atlas_list = {};
                    app.ListBox_Atlas.Items = app.gatp_setting.atlas_list;
                    app.gatp_setting.file_list = {};
                    app.gatp_setting.file_path_list = {};
                    app.ListBox_Files.Items = app.gatp_setting.file_list;
            end
        end

        % Button pushed function: Button_loadfiles
        function gatp_open_file(app, event)
            % Load input data
            app.gatp_setting.file_type=app.FileFormatDropDown.Value;
            switch app.gatp_setting.file_type
                case 1      % If image data
                    [fnc_temp_file,fnc_temp_path] = uigetfile('*.nii;*.nii.gz','Select One or More Files', 'MultiSelect','on');
                case 2      % If matrix
                    [fnc_temp_file,fnc_temp_path] = uigetfile('*.mat','Select One or More Files', 'MultiSelect','on');
            end

            if isequal(fnc_temp_file,0)
                return
            else
                if ~iscell(fnc_temp_file)
                    fnc_temp_file={fnc_temp_file};
                end
                app.gatp_setting.file_list = fnc_temp_file;
                app.gatp_setting.file_path_list = fnc_temp_path;
                app.ListBox_Files.Items = app.gatp_setting.file_list;
            end
        end

        % Value changed function: AtlasDropDown
        function gatp_atlas_type(app, event)
            value = app.AtlasDropDown.Value;
            switch value
                case 0
                    app.ListBox_Atlas.Enable = 'on';
                    app.Button_AddAtlas.Enable = 'on';
                    app.gatp_setting.atlas_list = {};
                    app.gatp_setting.atlas_path={};
                    app.ListBox_Atlas.Items = app.gatp_setting.atlas_list;
                case 1
                    app.ListBox_Atlas.Enable = 'off';
                    app.Button_AddAtlas.Enable = 'off';
                    app.gatp_setting.atlas_list = importdata(fullfile(app.gatp_setting.path,'atlas','BN_atlas_1_25mm.nii.txt'));
                    app.gatp_setting.atlas_path={};
                    app.ListBox_Atlas.Items = app.gatp_setting.atlas_list;
                case 2
                    app.ListBox_Atlas.Enable = 'off';
                    app.Button_AddAtlas.Enable = 'off';
                    app.gatp_setting.atlas_list = importdata(fullfile(app.gatp_setting.path,'atlas','AAL2v1_2mm.nii.txt'));
                    app.gatp_setting.atlas_path={};
                    app.ListBox_Atlas.Items = app.gatp_setting.atlas_list;
            end
        end

        % Button pushed function: Button_AddAtlas
        function gatp_open_atlas(app, event)
            % Open Atlas File
            switch app.FileFormatDropDown.Value
                case 1      % If input is image
                    [fnc_temp_file,fnc_temp_path] = uigetfile('*.nii;*.nii.gz','Select One or More Files', 'MultiSelect','on');
                    if isequal(fnc_temp_file,0)
                        return
                    else
                        if ~iscell(fnc_temp_file)
                            fnc_temp_file={fnc_temp_file};
                        end
                        app.gatp_setting.atlas_list = fnc_temp_file;
                        app.gatp_setting.atlas_path = fnc_temp_path;
                        app.ListBox_Atlas.Items = app.gatp_setting.atlas_list;
                    end
                case 2      % If input is Matlab Matrix
                    [fnc_temp_file,fnc_temp_path] = uigetfile('*.txt','Select ROI Name Files');
                    if isequal(fnc_temp_file,0)
                        return
                    else
                        temp_file=fullfile(fnc_temp_path,fnc_temp_file);
                        app.gatp_setting.atlas_list = importdata(temp_file);
                        app.gatp_setting.atlas_path = fnc_temp_path;
                        app.ListBox_Atlas.Items = app.gatp_setting.atlas_list;
                    end
            end
        end

        % Value changed function: WindowKernelDropDown
        function gatp_kernel(app, event)
            app.WindowKernelDropDown.Value = app.WindowKernelDropDown.Value;
            switch app.WindowKernelDropDown.Value
                case 1      % No kernel
                    app.sigmaEditFieldLabel.Enable = 'off';
                    app.sigmaEditField.Enable = 'off';
                case 2      % Gaussian kernel
                    app.sigmaEditFieldLabel.Enable = 'on';
                    app.sigmaEditField.Enable = 'on';
            end
        end

        % Value changed function: FilterDropDown
        function gatp_filter_type(app, event)
            app.gatp_setting.filter_type = app.FilterDropDown.Value;
            switch app.gatp_setting.filter_type
                case 1  % None
                    app.Filter_label2Label.Enable = 'off';
                    app.FilterEditField2.Enable = 'off';
                    app.Filter_label1EditFieldLabel.Enable = 'off';
                    app.FilterEditField1.Enable = 'off';
                    app.Filter_label2Label.Text = 'Filter Option';
                    app.Filter_label1EditFieldLabel.Text = 'Filter Option';
                    
                case 2  % Bandpass
                    app.Filter_label2Label.Enable = 'on';
                    app.FilterEditField2.Enable = 'on';
                    app.Filter_label1EditFieldLabel.Enable = 'on';
                    app.FilterEditField1.Enable = 'on';
                    app.Filter_label2Label.Text = 'Lower Limit (1/Hz)';
                    app.Filter_label1EditFieldLabel.Text = 'Upper Limit (1/Hz)';
                    
                case 3  % Highpass
                    app.Filter_label2Label.Enable = 'off';
                    app.FilterEditField2.Enable = 'off';
                    app.Filter_label1EditFieldLabel.Enable = 'on';
                    app.FilterEditField1.Enable = 'on';
                    app.Filter_label2Label.Text = 'Filter_option';
                    app.Filter_label1EditFieldLabel.Text = 'Cut-off Frequency (1/Hz)';
                    
                case 4  % Lowpass
                    app.Filter_label2Label.Enable = 'off';
                    app.FilterEditField2.Enable = 'off';
                    app.Filter_label1EditFieldLabel.Enable = 'on';
                    app.FilterEditField1.Enable = 'on';
                    app.Filter_label2Label.Text = 'Filter_option';
                    app.Filter_label1EditFieldLabel.Text = 'Cut-off Frequency (1/Hz)';
                    
                case 5  % Wavelet
                    app.Filter_label2Label.Enable = 'on';
                    app.FilterEditField2.Enable = 'on';
                    app.Filter_label1EditFieldLabel.Enable = 'on';
                    app.FilterEditField1.Enable = 'on';
                    app.Filter_label2Label.Text = 'Wavelet Selections';
                    app.Filter_label1EditFieldLabel.Text = 'Wavelet Levels';
            end
        end

        % Button pushed function: Button_Default
        function gatp_defaultset(app, event)
            % Update setting
            app.parameters_default();
            app.parameters_update_field();
        end

        % Button pushed function: SaveSettingsButton
        function gatp_savesetting(app, event)
            [fnc_temp_file,fnc_temp_path] = uiputfile('*.mat','Select directory to save settings','gatfd_setting.mat');
            if isequal(fnc_temp_file,0)
                return
            else
                % Load Settings
                app.parameters_update_setting();
                gatp_para=app.gatp_setting;
                save([fnc_temp_path,fnc_temp_file],'gatp_para');
            end
        end

        % Button pushed function: Button_LoadSetting
        function gatp_loadsetting(app, event)
            [fnc_temp_file,fnc_temp_path] = uigetfile('*.mat','Select Setting Files');
            if isequal(fnc_temp_file,0)
                return
            else
                temp_name=who('-file','gatfd_setting.mat');
                if ~ismember(temp_name, 'gatp_para')
                    errordlg('The setting file does not contains setting for GAT-FD Sliding Window Analysis','Wrong Setting File');
                    return
                end
                
                % Update the current setting
                load([fnc_temp_path,fnc_temp_file],'gatp_para');
                app.gatp_setting = gatp_para;
                app.parameters_update_field;
            end
        end

        % Button pushed function: RunButton
        function gatp_run_process(app, event)
            % Update settings
            fnc_pro_filelength = length(app.gatp_setting.file_list);
            app.parameters_update_setting();
            
            % Load input file
            switch app.gatp_setting.filter_type
                case 1
                    run_filter_setting1 = 0;
                    run_filter_setting2 = 0;
                case 2
                    run_filter_setting1 = str2num(app.gatp_setting.filter_setting1);
                    run_filter_setting2 = str2num(app.gatp_setting.filter_setting2);
                    if isempty(run_filter_setting1)||isempty(run_filter_setting2)
                        errordlg("Please enter correct band pass parameters","Error");
                        return
                    end
                    if run_filter_setting1>=run_filter_setting2
                        errordlg("Please enter correct band pass parameters","Error");
                        return
                    end
                case 3
                    run_filter_setting1 = str2num(app.gatp_setting.filter_setting1);
                    run_filter_setting2 = 0;
                    if isempty(run_filter_setting1)
                        errordlg("Please enter correct band pass parameters","Error");
                        return
                    end
                case 4
                    run_filter_setting1 = str2num(app.gatp_setting.filter_setting1);
                    run_filter_setting2 = 0;
                    if isempty(run_filter_setting1)
                        errordlg("Please enter correct band pass parameters","Error");
                        return
                    end
                case 5
                    run_filter_setting1 = str2num(app.gatp_setting.filter_setting1);
                    run_filter_setting2 = str2num(app.gatp_setting.filter_setting2);
                    if isempty(run_filter_setting1)||isempty(run_filter_setting2)
                        errordlg("Please enter correct band pass parameters","Error");
                        return
                    end
                otherwise
                    disp('filter type error')
            end
            
            % Check input file format
            if app.FileFormatDropDown.Value==1
                % Predefined data
                switch app.AtlasDropDown.Value
                    case 0
                        atl_len=length(app.gatp_setting.atlas_list);
                        if atl_len>1
                            fnc_pro_atlas_file=fullfile(app.gatp_setting.atlas_path,app.gatp_setting.atlas_list{1});
                            try
                                fnc_pro_atlas_info=niftiinfo(fnc_pro_atlas_file);
                            catch
                                errordlg('Please check if atlas file is correct','Failed Loading Nifti');
                                return
                            end
                            fnc_pro_atlas_masks=niftiread(fnc_pro_atlas_file);
                            for idx=2:atl_len
                                fnc_pro_atlas_file=fullfile(app.gatp_setting.atlas_path,app.gatp_setting.atlas_list{idx});
                                temp_file=niftiread(fnc_pro_atlas_file);
                                temp_file=double(temp_file>0);      % Binarize mask
                                fnc_pro_atlas_masks=fnc_pro_atlas_masks+temp_file*idx;
                            end
                        else
                            fnc_pro_atlas_file=fullfile(app.gatp_setting.atlas_path,app.gatp_setting.atlas_list{1});
                            try 
                                fnc_pro_atlas_info=niftiinfo(fnc_pro_atlas_file);
                            catch
                                errordlg('Please check if atlas file is correct','Failed Loading Nifti');
                                return
                            end
                            fnc_pro_atlas_masks=niftiread(fnc_pro_atlas_file);
                            atl_len=max(fnc_pro_atlas_masks(:));
                        end
                    case 1      % Brainetome 1.25mm
                        % Load atlas file
                        fnc_pro_atlas_file=fullfile(app.gatp_setting.path,'atlas','BN_atlas_1_25mm.nii');
                        fnc_pro_atlas_masks=niftiread(fnc_pro_atlas_file);
                        fnc_pro_atlas_info=niftiinfo(fnc_pro_atlas_file);
                        atl_len=246;
                    case 2      % AAL2v1 2mm
                        % Load atlas file
                        fnc_pro_atlas_file=fullfile(app.gatp_setting.path,'atlas','AAL2v1_2mm.nii.gz');
                        fnc_pro_atlas_masks=niftiread(fnc_pro_atlas_file);
                        fnc_pro_atlas_info=niftiinfo(fnc_pro_atlas_file);
                        atl_len=94;
                end                
                fnc_pro_atlas_size=size(fnc_pro_atlas_masks);
                fnc_pro_atlas_invtran=invert(fnc_pro_atlas_info.Transform);
                fnc_window_size=app.gatp_setting.window_size;
            elseif app.FileFormatDropDown.Value==2
                atl_len=length(app.gatp_setting.atlas_list);
                if atl_len<1
                    errordlg('Please load label','Failed Loading Nifti');
                    return
                end
                fnc_window_size=app.gatp_setting.window_size;
            end

            % Select output folder
            fnc_out_path = uigetdir("","Select Output Folder");
            if isequal(fnc_out_path,0)
                return
            end
            
            % Create process bar
            process_fig = uifigure;
            process_d = uiprogressdlg(process_fig,'Title','Processing');
            
            % Run program
            for i=1:fnc_pro_filelength
                % Settings
                fnc_in_file=fullfile(app.gatp_setting.file_path_list,app.gatp_setting.file_list{i});
                
                if app.FileFormatDropDown.Value==1
                    % Read initial file info
                    fnc_rawdata=niftiread(fnc_in_file);
                    fnc_rawdata_info=niftiinfo(fnc_in_file);
                    fnc_rawdata_len=size(fnc_rawdata,4);
                    fnc_window_count=fnc_rawdata_len-fnc_window_size+1;
                    
                    % Transform data to atlas space
                    % Initial transform matrix
                    process_d.Value=(i-1)/fnc_pro_filelength;
                    process_d.Message = {[num2str(i),'/',num2str(fnc_pro_filelength),': Registering Data']};
                    
                    if isequal(fnc_pro_atlas_info.Transform.T,fnc_rawdata_info.Transform.T)
                        fnc_data=fnc_rawdata;
                    else
                        fnc_data=zeros([fnc_pro_atlas_size,fnc_rawdata_len],"double");
                        
                        % Transform data into atlas space
                        fnc_rawdata_t=imwarp(fnc_rawdata(:,:,:,1),fnc_rawdata_info.Transform);
                        fnc_rawdata_tt=imwarp(fnc_rawdata_t,fnc_pro_atlas_invtran);
                        fnc_rawdata_tt_s=size(fnc_rawdata_tt);
                        
                        % Shift and trim data to match atlas
                        if fnc_rawdata_tt_s(1)>fnc_pro_atlas_size(1)
                            xshift=floor((fnc_rawdata_tt_s(1)-fnc_pro_atlas_size(1))/2);
                            axs=1;
                            axe=fnc_pro_atlas_size(1);
                            dxs=1+xshift;
                            dxe=fnc_pro_atlas_size(1)+xshift;
                        else
                            xshift=floor((fnc_pro_atlas_size(1)-fnc_rawdata_tt_s(1))/2);
                            axs=1+xshift;
                            axe=fnc_rawdata_tt_s(1)+xshift;
                            dxs=1;
                            dxe=fnc_rawdata_tt_s(1);
                        end
                            
                        if fnc_rawdata_tt_s(2)>fnc_pro_atlas_size(2)
                            xshift=floor((fnc_rawdata_tt_s(2)-fnc_pro_atlas_size(2))/2);
                            ays=1;
                            aye=fnc_pro_atlas_size(2);
                            dys=1+xshift;
                            dye=fnc_pro_atlas_size(2)+xshift;
                        else
                            xshift=floor((fnc_pro_atlas_size(2)-fnc_rawdata_tt_s(2))/2);
                            dys=1;
                            dye=fnc_rawdata_tt_s(2);
                            ays=1+xshift;
                            aye=fnc_rawdata_tt_s(2)+xshift;
                        end
                        
                        if fnc_rawdata_tt_s(3)>fnc_pro_atlas_size(3)
                            xshift=floor((fnc_rawdata_tt_s(3)-fnc_pro_atlas_size(3))/2);
                            azs=1;
                            aze=fnc_pro_atlas_size(3);
                            dzs=1+xshift;
                            dze=fnc_pro_atlas_size(3)+xshift;
                        else
                            xshift=floor((fnc_pro_atlas_size(3)-fnc_rawdata_tt_s(3))/2);
                            dzs=1;
                            dze=fnc_rawdata_tt_s(3);
                            azs=1+xshift;
                            aze=fnc_rawdata_tt_s(3)+xshift;
                        end
                        
                        % Apply to all frames
                        for ii=1:fnc_rawdata_len
                            fnc_rawdata_t=imwarp(fnc_rawdata(:,:,:,ii),fnc_rawdata_info.Transform);
                            fnc_rawdata_tt=imwarp(fnc_rawdata_t,fnc_pro_atlas_invtran);
                            fnc_data(axs:axe,ays:aye,azs:aze,ii)=fnc_rawdata_tt(dxs:dxe,dys:dye,dzs:dze);
                        end
                    end

                    % Calculate atlased data
                    process_d.Value=(i-0.8)/fnc_pro_filelength;
                    process_d.Message = {[num2str(i),'/',num2str(fnc_pro_filelength),': Applying Atlas']};
                    atlased_data=zeros(fnc_rawdata_len,atl_len,"double");
                    fnc_pro_atlas_masks_flat=fnc_pro_atlas_masks(:);
                    fnc_data_flat=reshape(fnc_data,fnc_pro_atlas_size(1)*fnc_pro_atlas_size(2)*fnc_pro_atlas_size(3),fnc_rawdata_len);
                    for ii=1:atl_len
                        process_d.Value=(i-0.8+0.2*ii/atl_len)/fnc_pro_filelength;
                        process_d.Message = {[num2str(i),'/',num2str(fnc_pro_filelength),': Applying Atlas ',num2str(ii),'/',num2str(atl_len)]};
                        temp_pos=fnc_pro_atlas_masks_flat==ii;
                        temp_value=fnc_data_flat(temp_pos,:);
                        %temp_value=temp_value(temp_value>0);    % Remove Zeros in calculating the mean.
                        atlased_data(:,ii)=mean(temp_value, 'omitnan');
                    end
                    
                elseif app.FileFormatDropDown.Value==2
                    temp_data=load(fnc_in_file);
                    temp_data=struct2cell(temp_data);
                    atlased_data=temp_data{1};
                    
                    fnc_rawdata_len=size(atlased_data,4);
                    fnc_window_count=fnc_rawdata_len-fnc_window_size+1;
                end
                
                process_d.Value=(i-0.6)/fnc_pro_filelength;
                
                % Filter
                switch app.gatp_setting.filter_type
                    case 1  % None
                        % Do nothing
                    case 2  % Bandpass
                        process_d.Value = (i-0.4)/fnc_pro_filelength;
                        process_d.Message = {[num2str(i),'/',num2str(fnc_pro_filelength),': Applying Bandpass filter']};
                        for ii=1:atl_len
                            atlased_data(:,ii)=bandpass(atlased_data(:,ii),[1/run_filter_setting2 1/run_filter_setting1],1/app.gatp_setting.tr);
                        end
                    case 3  % Highpass
                        process_d.Value = (i-0.4)/fnc_pro_filelength;
                        process_d.Message = {[num2str(i),'/',num2str(fnc_pro_filelength),': Applying Highpass filter']};
                        for ii=1:atl_len
                            atlased_data(:,ii)=highpass(atlased_data(:,ii),1/run_filter_setting1,1/app.gatp_setting.tr);
                        end
                    case 4  % Lowpass
                        process_d.Value = (i-0.4)/fnc_pro_filelength;
                        process_d.Message = {[num2str(i),'/',num2str(fnc_pro_filelength),': Applying Lowpass filter']};
                        for ii=1:atl_len
                            atlased_data(:,ii)=lowpass(atlased_data(:,ii),1/run_filter_setting1,1/app.gatp_setting.tr);
                        end
                    case 5  % Wavelet
                        process_d.Value = (i-0.4)/fnc_pro_filelength;
                        process_d.Message = {[num2str(i),'/',num2str(fnc_pro_filelength),': Calculating wavelet']};
                        for ii=1:atl_len
                            temp_data=modwt(atlased_data(:,ii),run_filter_setting1);
                            temp_idx=1:(run_filter_setting1+1);        % Index of excluded channels
                            temp_idx(run_filter_setting2)=[];
                            temp_data(temp_idx,:)=0;
                            atlased_data(:,ii)=imodwt(temp_data);
                        end
                    otherwise
                        disp("error");
                end

                % Calculate correlation
                corr_data=zeros(fnc_window_count,atl_len,atl_len,"double");
                process_d.Value = (i-0.2)/fnc_pro_filelength;
                process_d.Message = {[num2str(i),'/',num2str(fnc_pro_filelength),': Calculating Sliding Window']};
                if app.gatp_setting.kernel==1
                    for idx_window=1:fnc_window_count
                        temp_data=corrcoef(atlased_data(idx_window:idx_window-1+fnc_window_size,:));
                        temp_data(isnan(temp_data))=0;
                        corr_data(idx_window,:,:)=temp_data;
                    end
                elseif app.gatp_setting.kernel==2
                    for idx_window=1:fnc_window_count
                        temp_gi=1:app.gatp_setting.window_size;
                        temp_gm=floor(app.gatp_setting.window_size/2)+1;
                        temp_gau_mat=repmat(app.gauss_kernel(temp_gi,temp_gm,app.gatp_setting.kernel_setting),atl_len,1)';
                        temp_data=corrcoef(atlased_data(idx_window:idx_window-1+fnc_window_size,:).*temp_gau_mat);
                        temp_data(isnan(temp_data))=0;
                        corr_data(idx_window,:,:)=temp_data;
                    end
                end

                subj_data.d_atlas=atlased_data;
                subj_data.d_corr=corr_data;
                subj_data.d_setting=app.gatp_setting;
                subj_data.d_windowsize=app.gatp_setting.window_size;
                subj_data.d_stepsize=app.gatp_setting.step_size;
                subj_data.d_kernel=app.gatp_setting.kernel;
                subj_data.d_atlas_list=app.gatp_setting.atlas_list;
                
                % #####################
                % # Data include info #
                % #####################
                
                file_name_length=length(app.gatp_setting.file_list{i});
                if app.gatp_setting.file_list{i}(file_name_length-3:file_name_length)=='.nii'
                    fnc_pro_atlas_file=fullfile(fnc_out_path,app.gatp_setting.file_list{i}(1:file_name_length-4));
                elseif app.gatp_setting.file_list{i}(file_name_length-6:file_name_length)=='.nii.gz'
                    fnc_pro_atlas_file=fullfile(fnc_out_path,app.gatp_setting.file_list{i}(1:file_name_length-7));
                else
                    fnc_pro_atlas_file=fullfile(fnc_out_path,app.gatp_setting.file_list{i});
                end
                save([fnc_pro_atlas_file,'.mat'],'subj_data');
                process_d.Value = i/fnc_pro_filelength;
                process_d.Message = {[num2str(i),'/',num2str(fnc_pro_filelength),': Done']};
            end
            
            close(process_d);
            close(process_fig);
            f=msgbox("Finished");
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create GATFD_process_UIFigure and hide until all components are created
            app.GATFD_process_UIFigure = uifigure('Visible', 'off');
            app.GATFD_process_UIFigure.Position = [100 100 657 719];
            app.GATFD_process_UIFigure.Name = 'GAT-FD - Sliding Window Correlation Analysis v0.3a';

            % Create GridLayout
            app.GridLayout = uigridlayout(app.GATFD_process_UIFigure);
            app.GridLayout.ColumnWidth = {20, 32, 43, '2x', 100, 20, 80, '2x', '1x', 100, 20};
            app.GridLayout.RowHeight = {20, 22, 22, 22, 22, 22, 22, 22, 22, 22, '1x', 20, 22, 22, 30, '1x', 22, 22, 22, 22, 20};

            % Create Button_loadfiles
            app.Button_loadfiles = uibutton(app.GridLayout, 'push');
            app.Button_loadfiles.ButtonPushedFcn = createCallbackFcn(app, @gatp_open_file, true);
            app.Button_loadfiles.Layout.Row = 3;
            app.Button_loadfiles.Layout.Column = 5;
            app.Button_loadfiles.Text = 'Load Files';

            % Create Button_Default
            app.Button_Default = uibutton(app.GridLayout, 'push');
            app.Button_Default.ButtonPushedFcn = createCallbackFcn(app, @gatp_defaultset, true);
            app.Button_Default.Layout.Row = 17;
            app.Button_Default.Layout.Column = 10;
            app.Button_Default.Text = 'Default Setting';

            % Create Button_AddAtlas
            app.Button_AddAtlas = uibutton(app.GridLayout, 'push');
            app.Button_AddAtlas.ButtonPushedFcn = createCallbackFcn(app, @gatp_open_atlas, true);
            app.Button_AddAtlas.Enable = 'off';
            app.Button_AddAtlas.Layout.Row = 14;
            app.Button_AddAtlas.Layout.Column = [5 7];
            app.Button_AddAtlas.Text = 'Add Masks';

            % Create Button_LoadSetting
            app.Button_LoadSetting = uibutton(app.GridLayout, 'push');
            app.Button_LoadSetting.ButtonPushedFcn = createCallbackFcn(app, @gatp_loadsetting, true);
            app.Button_LoadSetting.Layout.Row = 18;
            app.Button_LoadSetting.Layout.Column = 10;
            app.Button_LoadSetting.Text = 'Load Settings';

            % Create SaveSettingsButton
            app.SaveSettingsButton = uibutton(app.GridLayout, 'push');
            app.SaveSettingsButton.ButtonPushedFcn = createCallbackFcn(app, @gatp_savesetting, true);
            app.SaveSettingsButton.Layout.Row = 19;
            app.SaveSettingsButton.Layout.Column = 10;
            app.SaveSettingsButton.Text = 'Save Settings';

            % Create RunButton
            app.RunButton = uibutton(app.GridLayout, 'push');
            app.RunButton.ButtonPushedFcn = createCallbackFcn(app, @gatp_run_process, true);
            app.RunButton.Layout.Row = 20;
            app.RunButton.Layout.Column = 10;
            app.RunButton.Text = 'Run';

            % Create ListBox_Atlas
            app.ListBox_Atlas = uilistbox(app.GridLayout);
            app.ListBox_Atlas.Items = {'Masks'};
            app.ListBox_Atlas.Enable = 'off';
            app.ListBox_Atlas.Layout.Row = [15 20];
            app.ListBox_Atlas.Layout.Column = [2 7];
            app.ListBox_Atlas.Value = {};

            % Create WindowSizeTRLabel
            app.WindowSizeTRLabel = uilabel(app.GridLayout);
            app.WindowSizeTRLabel.Layout.Row = 4;
            app.WindowSizeTRLabel.Layout.Column = [7 8];
            app.WindowSizeTRLabel.Text = 'Window Size (TR)';

            % Create EditField_windowsize
            app.EditField_windowsize = uieditfield(app.GridLayout, 'numeric');
            app.EditField_windowsize.Layout.Row = 4;
            app.EditField_windowsize.Layout.Column = [9 10];
            app.EditField_windowsize.Value = 20;

            % Create StepSizeTRLabel
            app.StepSizeTRLabel = uilabel(app.GridLayout);
            app.StepSizeTRLabel.Layout.Row = 5;
            app.StepSizeTRLabel.Layout.Column = [7 8];
            app.StepSizeTRLabel.Text = 'Step Size (TR)';

            % Create EditField_stepsize
            app.EditField_stepsize = uieditfield(app.GridLayout, 'numeric');
            app.EditField_stepsize.Layout.Row = 5;
            app.EditField_stepsize.Layout.Column = [9 10];
            app.EditField_stepsize.Value = 1;

            % Create WindowKernelDropDownLabel
            app.WindowKernelDropDownLabel = uilabel(app.GridLayout);
            app.WindowKernelDropDownLabel.Layout.Row = 9;
            app.WindowKernelDropDownLabel.Layout.Column = [7 8];
            app.WindowKernelDropDownLabel.Text = 'Window Kernel';

            % Create WindowKernelDropDown
            app.WindowKernelDropDown = uidropdown(app.GridLayout);
            app.WindowKernelDropDown.Items = {'None', 'Gaussian'};
            app.WindowKernelDropDown.ValueChangedFcn = createCallbackFcn(app, @gatp_kernel, true);
            app.WindowKernelDropDown.Layout.Row = 9;
            app.WindowKernelDropDown.Layout.Column = [9 10];
            app.WindowKernelDropDown.Value = 'None';

            % Create AtlasDropDownLabel
            app.AtlasDropDownLabel = uilabel(app.GridLayout);
            app.AtlasDropDownLabel.Layout.Row = 13;
            app.AtlasDropDownLabel.Layout.Column = [2 3];
            app.AtlasDropDownLabel.Text = 'Atlas';

            % Create AtlasDropDown
            app.AtlasDropDown = uidropdown(app.GridLayout);
            app.AtlasDropDown.Items = {'Brainnetome 1.25mm', 'AAL 2mm', 'Custom'};
            app.AtlasDropDown.ValueChangedFcn = createCallbackFcn(app, @gatp_atlas_type, true);
            app.AtlasDropDown.Layout.Row = 13;
            app.AtlasDropDown.Layout.Column = [4 7];
            app.AtlasDropDown.Value = 'Brainnetome 1.25mm';

            % Create LoadedFIlesLabel
            app.LoadedFIlesLabel = uilabel(app.GridLayout);
            app.LoadedFIlesLabel.Layout.Row = 3;
            app.LoadedFIlesLabel.Layout.Column = [2 3];
            app.LoadedFIlesLabel.Text = 'Loaded FIles';

            % Create ListBox_Files
            app.ListBox_Files = uilistbox(app.GridLayout);
            app.ListBox_Files.Items = {'Load Files'};
            app.ListBox_Files.Layout.Row = [4 11];
            app.ListBox_Files.Layout.Column = [2 5];
            app.ListBox_Files.Value = {};

            % Create sigmaEditFieldLabel
            app.sigmaEditFieldLabel = uilabel(app.GridLayout);
            app.sigmaEditFieldLabel.Enable = 'off';
            app.sigmaEditFieldLabel.Layout.Row = 10;
            app.sigmaEditFieldLabel.Layout.Column = [7 8];
            app.sigmaEditFieldLabel.Text = '\sigma';

            % Create sigmaEditField
            app.sigmaEditField = uieditfield(app.GridLayout, 'numeric');
            app.sigmaEditField.HorizontalAlignment = 'left';
            app.sigmaEditField.Enable = 'off';
            app.sigmaEditField.Layout.Row = 10;
            app.sigmaEditField.Layout.Column = [9 10];
            app.sigmaEditField.Value = 1;

            % Create FileFormatDropDownLabel
            app.FileFormatDropDownLabel = uilabel(app.GridLayout);
            app.FileFormatDropDownLabel.Layout.Row = 2;
            app.FileFormatDropDownLabel.Layout.Column = [2 3];
            app.FileFormatDropDownLabel.Text = 'File Format';

            % Create FileFormatDropDown
            app.FileFormatDropDown = uidropdown(app.GridLayout);
            app.FileFormatDropDown.Items = {'Image (Nifti)', 'Time series'};
            app.FileFormatDropDown.ValueChangedFcn = createCallbackFcn(app, @gatp_file_type, true);
            app.FileFormatDropDown.Layout.Row = 2;
            app.FileFormatDropDown.Layout.Column = [4 5];
            app.FileFormatDropDown.Value = 'Image (Nifti)';

            % Create FilterDropDownLabel
            app.FilterDropDownLabel = uilabel(app.GridLayout);
            app.FilterDropDownLabel.Layout.Row = 6;
            app.FilterDropDownLabel.Layout.Column = 7;
            app.FilterDropDownLabel.Text = 'Filter';

            % Create FilterDropDown
            app.FilterDropDown = uidropdown(app.GridLayout);
            app.FilterDropDown.Items = {'None', 'Bandpass', 'Highpass', 'Lowpass', 'Wavelet'};
            app.FilterDropDown.ValueChangedFcn = createCallbackFcn(app, @gatp_filter_type, true);
            app.FilterDropDown.Layout.Row = 6;
            app.FilterDropDown.Layout.Column = [9 10];
            app.FilterDropDown.Value = 'None';

            % Create Filter_label2Label
            app.Filter_label2Label = uilabel(app.GridLayout);
            app.Filter_label2Label.Enable = 'off';
            app.Filter_label2Label.Layout.Row = 8;
            app.Filter_label2Label.Layout.Column = [7 8];
            app.Filter_label2Label.Text = 'Filter_label2';

            % Create FilterEditField2
            app.FilterEditField2 = uieditfield(app.GridLayout, 'text');
            app.FilterEditField2.Enable = 'off';
            app.FilterEditField2.Layout.Row = 8;
            app.FilterEditField2.Layout.Column = [9 10];

            % Create Filter_label1EditFieldLabel
            app.Filter_label1EditFieldLabel = uilabel(app.GridLayout);
            app.Filter_label1EditFieldLabel.Enable = 'off';
            app.Filter_label1EditFieldLabel.Layout.Row = 7;
            app.Filter_label1EditFieldLabel.Layout.Column = [7 8];
            app.Filter_label1EditFieldLabel.Text = 'Filter_label1';

            % Create FilterEditField1
            app.FilterEditField1 = uieditfield(app.GridLayout, 'text');
            app.FilterEditField1.Enable = 'off';
            app.FilterEditField1.Layout.Row = 7;
            app.FilterEditField1.Layout.Column = [9 10];

            % Create TRsEditFieldLabel
            app.TRsEditFieldLabel = uilabel(app.GridLayout);
            app.TRsEditFieldLabel.Layout.Row = 3;
            app.TRsEditFieldLabel.Layout.Column = 7;
            app.TRsEditFieldLabel.Text = 'TR (s)';

            % Create TRsEditField
            app.TRsEditField = uieditfield(app.GridLayout, 'numeric');
            app.TRsEditField.Layout.Row = 3;
            app.TRsEditField.Layout.Column = [9 10];
            app.TRsEditField.Value = 1;

            % Create AnalysisDropDownLabel
            app.AnalysisDropDownLabel = uilabel(app.GridLayout);
            app.AnalysisDropDownLabel.Layout.Row = 2;
            app.AnalysisDropDownLabel.Layout.Column = [7 8];
            app.AnalysisDropDownLabel.Text = 'Analysis';

            % Create AnalysisDropDown
            app.AnalysisDropDown = uidropdown(app.GridLayout);
            app.AnalysisDropDown.Items = {'Static Network', 'Dynamic Network'};
            app.AnalysisDropDown.Layout.Row = 2;
            app.AnalysisDropDown.Layout.Column = [9 10];
            app.AnalysisDropDown.Value = 'Static Network';

            % Show the figure after all components are created
            app.GATFD_process_UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = gatfd_ui_process_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.GATFD_process_UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.GATFD_process_UIFigure)
        end
    end
end