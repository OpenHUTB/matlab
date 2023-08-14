function fcncallobj_argSel_cb(tag,dlg,fco)



    if~strcmp(class(dlg),'DAStudio.Dialog')
        return;
    end


    selIdx=dlg.getWidgetValue(tag);
    currSource=[];


    if strcmp(tag,'obj_in_arg_sel_tag')
        fcaSource=fco.Arguments(selIdx+1);
        currScope='input';
        imd=DAStudio.imDialog.getIMWidgets(dlg);
        imd.clickApply(dlg);
        if~isempty(selIdx)
            dlg.setWidgetValue('obj_out_arg_sel_tag',[]);
        else
            return;
        end
    end



    currCache=slInternal('FcnCallEditorCache');
    currIdx=isempty(currCache);



    if~currIdx&&isequal(currCache.Arg,fcaSource)

    else
        oldCache=currCache;

        currCache.ArgType=currScope;
        currCache.ArgIdx=selIdx+1;
        currCache.Arg=fcaSource;
        currCache.ID=fco.getUUID;%#ok<*NASGU>


        needsApply=0;
        if strcmp(class(dlg),'DAStudio.Dialog')
            notApplied=dlg.hasUnappliedChanges;
        else
            notApplied=false;
        end

        if((~isequal(oldCache.ArgType,currCache.ArgType)||...
            ~isequal(oldCache.ArgIdx,currCache.ArgIdx))&&...
            notApplied)
            needsApply=1;
        end

        if needsApply
            unAppliedArg=Simulink.FunctionCallArgument;
            unAppliedArg.Name=dlg.getWidgetValue('name_tag');
            unAppliedArg.Dimensions=str2double(dlg.getWidgetValue('dim_tag'));

            cplxVal=dlg.getWidgetValue('complex_tag');
            if cplxVal==0
                cplxVal='auto';
            elseif cplxVal==1
                cplxVal='real';
            else
                cplxVal='complex';
            end

            minVal=str2double(dlg.getWidgetValue('minimum_tag'));
            if isnan(minVal)
                minVal=[];
            end
            maxVal=str2double(dlg.getWidgetValue('maximmum_tag'));
            if isnan(maxVal)
                maxVal=[];
            end

            unAppliedArg.Complexity=cplxVal;
            unAppliedArg.Min=minVal;
            unAppliedArg.Max=maxVal;
            unAppliedArg.DataType=dlg.getWidgetValue('datatypetag');

            if strcmp(oldCache.ArgType,'input')
                if~isArgEqual(fco.InputArguments(oldCache.ArgIdx),unAppliedArg)
                    button=questdlg(DAStudio.message('modelexplorer:DAS:DA_APPLY_CHANGES_DESC_MSG'),...
                    [class(fco),' - ',DAStudio.message('modelexplorer:DAS:ME_APPLY_CHANGES_GUI')],...
                    DAStudio.message('modelexplorer:DAS:DA_APPLY_MSG'),...
                    DAStudio.message('modelexplorer:DAS:ME_IGNORE_GUI'),...
                    DAStudio.message('modelexplorer:DAS:ME_IGNORE_GUI'));
                    if strcmpi(button,'Apply')
                        fco.InputArguments(oldCache.ArgIdx)=unAppliedArg;
                        setInBaseWks(fco);

                        imd=DAStudio.imDialog.getIMWidgets(dlg);
                        imd.clickApply(dlg);
                        dlg.setSource(fco);
                    else

                    end
                end
            else
                if~isArgEqual(fco.OutputArguments(oldCache.ArgIdx),unAppliedArg)
                    button=questdlg(DAStudio.message('modelexplorer:DAS:DA_APPLY_CHANGES_DESC_MSG'),...
                    [class(fco),' - ',DAStudio.message('modelexplorer:DAS:ME_APPLY_CHANGES_GUI')],...
                    DAStudio.message('modelexplorer:DAS:DA_APPLY_MSG'),...
                    DAStudio.message('modelexplorer:DAS:ME_IGNORE_GUI'),...
                    DAStudio.message('modelexplorer:DAS:ME_IGNORE_GUI'));
                    if strcmpi(button,'Apply')
                        fco.OutputArguments(oldCache.ArgIdx)=unAppliedArg;
                        setInBaseWks(fco);

                        imd=DAStudio.imDialog.getIMWidgets(dlg);
                        imd.clickApply(dlg);
                        dlg.setSource(fco);
                    else

                    end
                end
            end
            dlg.refresh;
        end

        slInternal('FcnCallEditorCache',currCache);
    end


    function equality=isArgEqual(arg1,arg2)



        if(isequal(arg1.Name,arg2.Name)&&...
            isequal(arg1.Dimensions,arg2.Dimensions)&&...
            isequal(arg1.DataType,arg2.DataType)&&...
            isequal(arg1.Complexity,arg2.Complexity)&&...
            isequal(arg1.Min,arg2.Min)&&...
            isequal(arg1.Max,arg2.Max))
            equality=true;
        else
            equality=false;
        end


        function setInBaseWks(fco)


            list=evalin('base','who');
            currID=fco.getUUID();
            for cnt=1:length(list)
                varName=list{cnt};
                className=evalin('base',['class(',varName,')']);

                if strcmp(className,'Simulink.FunctionCall')
                    varID=evalin('base',[varName,'.getUUID()']);
                    if isequal(varID,currID)
                        assignin('base',varName,fco);
                        break;
                    end
                end
            end

