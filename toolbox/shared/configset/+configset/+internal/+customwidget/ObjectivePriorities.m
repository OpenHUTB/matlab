function out=ObjectivePriorities(cs,name,direction,widgetVals)



    if direction==0
        out=loc_param_to_widget(cs,name);
    elseif direction==1
        out=loc_widget_to_param(cs,name,widgetVals{1});
    end

    function out=loc_param_to_widget(cs,name)

        isERT=strcmp(cs.getProp('IsERTTarget'),'on');
        val=cs.getProp(name);
        addEllipsis=false;

        if isERT
            grtValue='';
            if isempty(val)
                val={''};
            else
                if exist('rtw.codegenObjectives.ObjectiveCustomizer','class')>0
                    OCInitSuccess=true;
                else
                    OCInitSuccess=false;
                end
                cm=DAStudio.CustomizationManager;
                if OCInitSuccess&&cm.ObjectiveCustomizer.initialized
                    if length(val)>3
                        addEllipsis=true;
                        val=val(1:3);
                    end
                    for i=1:length(val)
                        opName=cm.ObjectiveCustomizer.IDToNameHash.get(val{i});
                        if~isempty(opName)
                            val{i}=opName;
                        end
                    end
                end
            end
            ertValue=strjoin(cellfun(@loc_translate,val,'UniformOutput',false),', ');
            if addEllipsis
                ertValue=[ertValue,', ...'];
            end
        else
            ertValue='';

            if isempty(val)
                grtValue='Unspecified';
            else
                grtValue=val{1};
            end
        end
        out={grtValue,ertValue,''};

        function out=loc_widget_to_param(~,~,val)
            if strcmp(val,'Unspecified')
                out=[];
            else
                out={val};
            end

            function obj=loc_translate(objName)
                switch objName
                case{'','Unspecified'}
                    obj=message('RTW:configSet:sanityCheckUnspecified').getString;
                case 'Traceability'
                    obj=message('RTW:configSet:sanityCheckTraceability').getString;
                case 'Safety precaution'
                    obj=message('RTW:configSet:sanityCheckSafetyprecaution').getString;
                case 'Debugging'
                    obj=message('RTW:configSet:sanityCheckDebugging').getString;
                case 'RAM efficiency'
                    obj=message('RTW:configSet:sanityCheckEfficiencyRAM').getString;
                case 'ROM efficiency'
                    obj=message('RTW:configSet:sanityCheckEfficiencyROM').getString;
                case 'Execution efficiency'
                    obj=message('RTW:configSet:sanityCheckEfficiencyspeed').getString;
                case 'MISRA C:2012 guidelines'
                    obj=message('RTW:configSet:sanityCheckMisrac').getString;
                otherwise
                    obj=objName;
                end
