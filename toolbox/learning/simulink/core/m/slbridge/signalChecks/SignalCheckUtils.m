

classdef SignalCheckUtils<handle

    methods(Static)

        function val=getMaskWSVariable(block,varname)
            v=get_param(block,'MaskWSVariables');
            names={v.Name};
            val=v(strcmp(varname,names)).Value;
        end

        function setMaskWSVariable(block,varname,valstr)
            names=get_param(block,'MaskNames');
            current_values=get_param(block,'MaskValues');
            current_values{ismember(names,varname)}=valstr;
            set_param(block,'MaskValues',current_values);
        end

        function[fh,ah]=getFigureHandle(block,varargin)
            if isempty(varargin)
                fh=figure('visible','off');
                fh.OuterPosition(3)=240;fh.OuterPosition(4)=230;
                fh.MenuBar='none';
                fh.PaperPositionMode='auto';



            else

                fh=findobj(0,'type','Figure','tag',block);
                if~isempty(fh)

                    figure(fh);
                    delete(fh.Children);
                else
                    fh=figure;
                    fh.Tag=block;
                end
            end
            fh.Name=block;
            fh.NumberTitle='off';
            fh.InvertHardcopy='off';
            fh.NextPlot='add';
            ah=axes(fh);
            if isempty(varargin)
                ah.FontSize=8;
            end
        end

        function openSignalInPlotWindow(block)
            graderType=SignalCheckUtils.getGraderType(block);
            switch graderType
            case 'signal'
                SignalAssessment.openSignalInPlotWindow(block);
            case 'mlsignal'
                SignalMATLABCheck.openSignalInPlotWindow(block);
            end
        end

        function logFileName=getLogFileName(block)
            toFileBlock=[block,'/To File'];
            logFileName=get_param(toFileBlock,'Filename');
        end

        function clearTempSignal(block)
            task=get_param(block,'task');
            log_file_location=fullfile(tempdir,'signalCheck',['task',task,'.mat']);

            if exist(log_file_location,'file')
                delete(log_file_location);
            end
        end

        function updatePassStatus(block)
            libraryLink=get_param(block,'ReferenceBlock');
            if contains(libraryLink,'MATLAB Signal')
                SignalMATLABCheck.updatePassStatus(block);
            elseif contains(libraryLink,'Assessment')
                SignalAssessment.updatePassStatus(block);
            elseif contains(libraryLink,'MATLAB Model')
                ModelMATLABCheck.updatePassStatus(block);
            elseif contains(libraryLink,'Stateflow Model')
                ModelStateflowCheck.updatePassStatus(block);
            end
        end

        function graderType=getGraderType(block)
            libraryLink=get_param(block,'ReferenceBlock');
            if contains(libraryLink,'MATLAB Signal')
                graderType='mlsignal';
            elseif contains(libraryLink,'Assessment')
                graderType='signal';
            elseif contains(libraryLink,'MATLAB Model')
                graderType='mlmodel';
            elseif contains(libraryLink,'Stateflow Model')
                graderType='sfmodel';
            elseif isempty(libraryLink)
                graderType='noTasks';
            end
        end

        function[status,requirements]=getRequirements(block)
            evalFunc=get_param(block,'mlfunc');
            evalFunc=evalFunc(2:end-1);

            [status,requirements]=feval(evalFunc,block);

            userData=str2double(get_param(block,'pass'));
            if userData==-1
                status=double(status);
                status(:)=-1;
            end
        end

        function ylimits=calculateYLims(ah)
            plotLines=ah.Children;
            ylimits=ah.YLim;

            plotLimits=zeros(numel(plotLines),2);

            for idx=1:numel(plotLines)
                plotLimits(idx,1)=min(plotLines(idx).YData);
                plotLimits(idx,2)=max(plotLines(idx).YData);
            end

            if min(plotLimits(:,1))>0
                plotMin=floor(min(plotLimits(:,1))*.9);
            else
                plotMin=floor(min(plotLimits(:,1))*1.1);
            end
            if max(plotLimits(:,2))>0
                plotMax=ceil(max(plotLimits(:,2))*1.1);
            else
                plotMax=ceil(max(plotLimits(:,2))*.9);
            end

            if ylimits(1)>plotMin
                ylimits(1)=plotMin;
            end
            if ylimits(2)<plotMax
                ylimits(2)=plotMax;
            end
        end

        function dockedDlg=findSignalDockedDialog()

            dlgs=DAStudio.ToolRoot.getOpenDialogs;

            dockedDlg=[];

            for idx=1:numel(dlgs)
                if strcmp(dlgs(idx).dialogTag,learning.simulink.slAcademy.EditorTab.ASSESS_PANE_DOCKED_TAG)
                    dockedDlg=dlgs(idx);
                    break;
                end
            end
        end
    end

end
