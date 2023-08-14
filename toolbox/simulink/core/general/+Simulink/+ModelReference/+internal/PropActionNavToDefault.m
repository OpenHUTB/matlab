classdef PropActionNavToDefault<Simulink.ModelReference.internal.PropAction




    methods(Static=true)



        function action=build(blkPath,argName,argValue,isFromDialog)



            action=[];
            if slfeature('ModelArgumentDefaultVal')<4||isFromDialog


                return;
            end


            if~isequal(argValue,DAStudio.message(...
                'Simulink:modelReference:ModelArgDefaultInternalValue'))
                return;
            end


            mdl_name=Simulink.ModelReference.internal.PropAction.getModelName(blkPath);
            if isempty(mdl_name)
                return;
            end


            action.enabled=false;
            action.visible=true;
            action.command='';
            action.label='';


            srcPath='';
            srcArgName='';
            try
                info=slInternal('getInstanceParameterCachedInfo',...
                blkPath,argName);
                if~isempty(info)&&~isempty(info.DefaultValueSource)&&...
                    ~isempty(info.DefaultValueSource.Path)&&...
                    ~isempty(info.DefaultValueSource.ParamName)

                    action.enabled=true;
                    action.visible=true;
                    srcPath=info.DefaultValueSource.Path;
                    srcArgName=info.DefaultValueSource.ParamName;
                end
            catch
            end


            if action.enabled
                assert(action.visible);
                instP=Simulink.ModelReference.internal.PropAction.getInstParamInfo(...
                blkPath,argName);
                assert(~isempty(instP),'Could not find the requested instance parameter.');
                if instP.Argument&&...
                    slfeature('ModelArgumentDefaultVal')<5
                    action.enabled=false;
                    action.visible=false;
                end
            end


            action.label=DAStudio.message(...
            'Simulink:dialog:VariableContextMenu_NavigateBelow');
            action.command=[...
'slprivate(''Simulink.ModelReference.internal.PropActionNavToDefault.run'', '''...
            ,mdl_name,''', ''',blkPath,''', ''',argName,''', '''...
            ,srcPath,''', ''',srcArgName,''');'];
        end




        function run(mdlName,blkPath,argName,srcPath,srcArgName)


            assert(~isempty(srcPath)&&~isempty(srcArgName),...
            'No default value information is available');



            bpArray=Simulink.ModelReference.internal.PropActionNavToDefault....
            getBlockPathFromTopToCurrentLevel(mdlName,blkPath);
            if isempty(bpArray)
                return;
            end
            isProtected=Simulink.ModelReference.internal.PropActionNavToDefault....
            checkIfPathToProtectedModel(bpArray);
            if(isProtected)
                return;
            end


            instP=Simulink.ModelReference.internal.PropAction.getInstParamInfo(...
            blkPath,argName);
            assert(~isempty(instP),'Could not find the requested instance parameter.')



            isBottomModel=~contains(srcPath,'/');
            if isBottomModel

                bpArray=[bpArray;instP.Path];
                isProtected=Simulink.ModelReference.internal.PropActionNavToDefault....
                checkIfPathToProtectedModel(instP.Path);
                if(isProtected)
                    return;
                end
            else






                found=false;
                for i=1:numel(instP.Path)
                    path=instP.Path(i);
                    if isequal(path,{srcPath})
                        found=true;
                        break;
                    end
                    bpArray=[bpArray;path];
                    isProtected=Simulink.ModelReference.internal.PropActionNavToDefault....
                    checkIfPathToProtectedModel(path);
                    if(isProtected)
                        return;
                    end
                end

                if~found

                    return;
                end
            end


            bp=Simulink.BlockPath(bpArray);
            try
                bp.open('openType','NEW_TAB')
            catch

                return;
            end


            Simulink.ModelReference.internal.PropActionNavToDefault.highlightPrmRowsInMDE(...
            srcPath,{srcArgName});
        end
    end

    methods(Static=true,Access=private)





        function highlightPrmRowsInMDE(blkPath,prmNames)
            try
                blkObj=get_param(blkPath,'Object');
                studio=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
                ss=studio.getComponent('GLUE2:SpreadSheet','ModelData');
                dlg=ss.getTitleView;
                dataView=dlg.getDialogSource;


                dataVwRowSelWrapper=SimulinkInternal.DataViewRowSelectionWrapper(...
                blkObj,prmNames);


                dataView.queueItemSelection(dataVwRowSelWrapper,"Parameters");
            catch
            end
        end






        function blkpthArray=getBlockPathFromTopToCurrentLevel(mdlName,blkPath)
            try
                mdlHdl=get_param(mdlName,'handle');
                mdlStudio=SLM3I.SLDomain.getLastActiveStudioAppFor(mdlHdl);
                if(isempty(mdlStudio))


                    topStudio=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
                    topEditor=topStudio.App.getActiveEditor;
                    hId=topEditor.getHierarchyId;
                    hdl=get_param(blkPath,'handle');
                    topBp=Simulink.BlockPath.fromHierarchyIdAndHandle(hId,hdl);
                    blkpthArray=topBp.convertToCell;
                else

                    blkpthArray={blkPath};
                end
            catch
                blkpthArray={};
            end
        end





        function isProtected=checkIfPathToProtectedModel(path)
            isProtected=false;
            for i=1:length(path)
                [isProtected,fullName]=slInternal('getReferencedModelFileInformation',get_param(path{i},'ModelFile'));
                if(isProtected)
                    opts=slInternal('getProtectedModelExtraInformation',fullName);
                    errordlg(DAStudio.message('Simulink:protectedModel:CannotOpenProtectedModelMessage',path{i},opts.modelName),...
                    DAStudio.message('Simulink:dialog:VariableContextMenu_NavigateBelow'));
                    break;
                end
            end
        end

    end
end
