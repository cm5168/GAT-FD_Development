classdef GATFD_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        GATFDUIFigure                matlab.ui.Figure
        GridLayout                   matlab.ui.container.GridLayout
        SlidingWindowAnalysisButton  matlab.ui.control.Button
        NetworkAnalysisButton        matlab.ui.control.Button
        DisplayButton                matlab.ui.control.Button
        TaskDesignButton             matlab.ui.control.Button
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            movegui(app.GATFDUIFigure,'center');
        end

        % Button pushed function: SlidingWindowAnalysisButton
        function gat_main_swc(app, event)
            gatfd_ui_process;
        end

        % Button pushed function: NetworkAnalysisButton
        function gat_main_network(app, event)
            gatfd_ui_network;
        end

        % Button pushed function: DisplayButton
        function gat_main_disp(app, event)
            gatfd_ui_view;
        end

        % Button pushed function: TaskDesignButton
        function gat_main_design(app, event)
            gatfd_ui_design;
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create GATFDUIFigure and hide until all components are created
            app.GATFDUIFigure = uifigure('Visible', 'off');
            app.GATFDUIFigure.Position = [100 100 240 360];
            app.GATFDUIFigure.Name = 'GAT_FD v0.3a';
            app.GATFDUIFigure.Resize = 'off';

            % Create GridLayout
            app.GridLayout = uigridlayout(app.GATFDUIFigure);
            app.GridLayout.ColumnWidth = {'1x', 160, '1x'};
            app.GridLayout.RowHeight = {'1x', 40, '1x', 40, '1x', 40, '1x', 40, '1x'};

            % Create SlidingWindowAnalysisButton
            app.SlidingWindowAnalysisButton = uibutton(app.GridLayout, 'push');
            app.SlidingWindowAnalysisButton.ButtonPushedFcn = createCallbackFcn(app, @gat_main_swc, true);
            app.SlidingWindowAnalysisButton.Layout.Row = 2;
            app.SlidingWindowAnalysisButton.Layout.Column = 2;
            app.SlidingWindowAnalysisButton.Text = 'Sliding-Window Analysis';

            % Create NetworkAnalysisButton
            app.NetworkAnalysisButton = uibutton(app.GridLayout, 'push');
            app.NetworkAnalysisButton.ButtonPushedFcn = createCallbackFcn(app, @gat_main_network, true);
            app.NetworkAnalysisButton.Layout.Row = 6;
            app.NetworkAnalysisButton.Layout.Column = 2;
            app.NetworkAnalysisButton.Text = 'Network Analysis';

            % Create DisplayButton
            app.DisplayButton = uibutton(app.GridLayout, 'push');
            app.DisplayButton.ButtonPushedFcn = createCallbackFcn(app, @gat_main_disp, true);
            app.DisplayButton.Layout.Row = 8;
            app.DisplayButton.Layout.Column = 2;
            app.DisplayButton.Text = 'Display';

            % Create TaskDesignButton
            app.TaskDesignButton = uibutton(app.GridLayout, 'push');
            app.TaskDesignButton.ButtonPushedFcn = createCallbackFcn(app, @gat_main_design, true);
            app.TaskDesignButton.Layout.Row = 4;
            app.TaskDesignButton.Layout.Column = 2;
            app.TaskDesignButton.Text = 'Task Design';

            % Show the figure after all components are created
            app.GATFDUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = GATFD_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.GATFDUIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.GATFDUIFigure)
        end
    end
end