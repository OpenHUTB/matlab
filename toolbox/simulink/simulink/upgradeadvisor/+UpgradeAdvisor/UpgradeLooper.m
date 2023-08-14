

classdef UpgradeLooper<handle

    properties(Access=private)
References
RootModelIndex
AnalyzisOrderList



CurrentEntryIndex

CleanUp
CheckData
    end

    methods
        function looper=UpgradeLooper(rootModel)

            persistent pLooper

            if isempty(pLooper)||nargin>0

                if nargin>0
                    looper.CurrentEntryIndex=1;
                    looper.addReference(rootModel);
                    looper.RootModelIndex=1;
                    looper.CheckData=pLooper.CheckData;
                else
                    looper.pInitialise;
                end
                pLooper=looper;
            else
                looper=pLooper;
            end

        end


        function setCheckData(looper,key,value)
            if(isempty(looper.CheckData))
                looper.pResetCheckData();
            end

            looper.CheckData(key)=value;
        end

        function data=getCheckData(looper,key)
            if(isempty(looper.CheckData))
                looper.pResetCheckData();
            end

            if(looper.CheckData.isKey(key))
                data=looper.CheckData(key);
            else
                data=[];
            end
        end


        function addCleanUp(looper,c)
            looper.CleanUp=[looper.CleanUp;c];
        end

        function clear(looper)
            looper.pInitialise();
        end

        function validModel=addReference(looper,modelName,internalHarnessPath)


            if looper.RootModelIndex<0
                DAStudio.error('SimulinkUpgradeAdvisor:tasks:LooperObjectNoRootModel')
            end
            if nargin<3
                internalHarnessPath='';
            end
            validModel='';
            newReference=looper.pCreateReference(modelName,internalHarnessPath);
            if~isempty(newReference)

                looper.AnalyzisOrderList=[];
                validModel=modelName;
                if isempty(looper.References)
                    looper.References=newReference;
                else
                    looper.References(end+1)=newReference;
                end
            end
        end


        function[m,compile]=getCurrentModelName(looper)
            list=looper.pGetAnalyzisOrderList;
            if looper.CurrentEntryIndex>0&&~isempty(list)
                list=looper.pGetAnalyzisOrderList;
                thisEntry=list(looper.CurrentEntryIndex);
                m=looper.References(thisEntry.index).name;
                compile=thisEntry.compile;
            else
                m='';
                compile='';
            end
        end

        function testHarnesses=getTestHarnessesInCurrentSession(looper)
            testHarnesses=looper.References([looper.References(:).isTestHarness]);
        end

        function setCurrentModel(looper,modelName)

            assert(isInCurrentSession(looper,modelName));

            ind=find(strcmp(modelName,looper.getModelNames)==true);
            list=looper.pGetAnalyzisOrderList;

            h=find([list.index]==ind);


            looper.CurrentEntryIndex=h(1);
        end

        function m=getRootModelName(looper)
            if looper.RootModelIndex<0
                m='';
            else
                rootModelRef=looper.References(looper.RootModelIndex);
                m=rootModelRef.name;
            end
        end

        function[next,compile,isPenultimate]=getNextModelToAnalyze(looper)


            ind=pGetNextLoopInd(looper);

            if ind<0
                next='';
                compile='';
                isPenultimate=false;
            else
                entry=looper.AnalyzisOrderList(ind);
                next=looper.References(entry.index);
                compile=entry.compile;
                isPenultimate=compile&&strcmp(looper.getRootModelName,next.name);
            end
        end

        function incrementReferenceLoopCount(looper)

            ind=pGetNextLoopInd(looper);
            looper.CurrentEntryIndex=ind;
        end

        function m=getModelNames(looper)
            if isstruct(looper.References)
                m={looper.References.name};
            else
                m={};
            end
        end

        function sortedModels=getSortedModelNames(looper)
            models=getModelNames(looper);
            if isempty(models)
                sortedModels={};
                return
            end
            order=[looper.pDetermineAnalysisOrder.index];
            models=getModelNames(looper);
            sortedModels=models(order);
        end

        function b=isInCurrentSession(looper,modelName)

            if numel(looper.References)==0
                b=false;
                return
            end
            fp=i_whichNoThrow(modelName);
            b=ismember(fp,{looper.References.fullpath});
            if~b


                [modelPath,modelName,modelExt]=fileparts(fp);
                if strcmp(modelExt,'.slx')
                    MDLFile=fullfile(modelPath,[modelName,'.mdl']);
                    [b,index]=...
                    ismember(MDLFile,{looper.References.fullpath});
                    if b








                        looper.References(index).fullpath=fp;
                    end
                end
            end
        end


        function html=getHTMLReferenceTree(looper)








            html='';
            if isempty(looper.References)
                return
            end

            indCurrent=looper.CurrentEntryIndex;
            indNext=looper.pGetNextLoopInd;

            for jj=1:numel(looper.AnalyzisOrderList)
                thisLoopEntry=looper.AnalyzisOrderList(jj);
                thisReference=looper.References(thisLoopEntry.index);
                thisModel=thisReference.name;


                decoration='';
                if thisReference.isLibrary
                    description=sprintf('%s: ',...
                    DAStudio.message('SimulinkUpgradeAdvisor:tasks:LooperLibraryDecoration'));
                elseif thisReference.isTestHarness
                    description=sprintf('%s: ',...
                    DAStudio.message('SimulinkUpgradeAdvisor:tasks:LooperTestHarnessDecoration'));
                elseif thisReference.isSubSystemReference
                    description=sprintf('%s: ',...
                    DAStudio.message('SimulinkUpgradeAdvisor:tasks:LooperSubsystemReferenceDecoration'));
                else
                    description=sprintf('%s: ',...
                    DAStudio.message('SimulinkUpgradeAdvisor:tasks:LooperModelDecoration'));
                end

                if thisReference.isMissing||~exist(thisReference.fullpath,'file')
                    NotFound=DAStudio.message('SimulinkUpgradeAdvisor:tasks:LooperFileNotFound');
                    decoration=[decoration,' ',NotFound];%#ok<AGROW>
                end

                if jj==indCurrent
                    Current=DAStudio.message('SimulinkUpgradeAdvisor:tasks:LooperCurrent');
                    decoration=[decoration,' ',Current];%#ok<AGROW>
                    thisModel=['<b>',thisModel,'</b>'];%#ok<AGROW>
                end
                if jj==indNext
                    Next=DAStudio.message('SimulinkUpgradeAdvisor:tasks:LooperNext');
                    decoration=[decoration,' ',Next];%#ok<AGROW>
                end
                if thisLoopEntry.compile
                    CompileOrNot='^';
                else
                    CompileOrNot='';
                end

                html=[html,'<ul><li>',CompileOrNot,description,thisModel,decoration,'</li></ul>'];%#ok<AGROW>
            end

        end
    end

    methods(Access=private)

        function list=pDetermineAnalysisOrder(looper)

























            if isempty(looper.References)

                list=[];
                return
            end




            modelIndex=[looper.References.isModel]&~[looper.References.isMissing];

            rootEntry=i_new_entry(looper.RootModelIndex,false);

            list=rootEntry;


            for jj=1:numel(modelIndex)
                if modelIndex(jj)&&~(jj==looper.RootModelIndex)
                    list(end+1)=i_new_entry(jj,false);%#ok<AGROW>
                end
            end


            for jj=1:numel(modelIndex)
                if~modelIndex(jj)&&~(jj==looper.RootModelIndex)&&...
                    looper.References(jj).isMissing
                    list(end+1)=i_new_entry(jj,false);%#ok<AGROW>
                end
            end


            for jj=1:numel(modelIndex)
                if~modelIndex(jj)&&~(jj==looper.RootModelIndex)...
                    &&looper.References(jj).isSubSystemReference
                    list(end+1)=i_new_entry(jj,false);%#ok<AGROW>
                end
            end

            for jj=1:numel(modelIndex)
                if~modelIndex(jj)&&~(jj==looper.RootModelIndex)...
                    &&looper.References(jj).isLibrary
                    list(end+1)=i_new_entry(jj,false);%#ok<AGROW>
                end
            end

            for jj=1:numel(modelIndex)
                if modelIndex(jj)&&~(jj==looper.RootModelIndex)

                    list(end+1)=i_new_entry(jj,true);%#ok<AGROW>
                end
            end


            if looper.References(looper.RootModelIndex).isModel
                list(end+1)=i_new_entry(looper.RootModelIndex,true);
            end

            looper.AnalyzisOrderList=list;
        end

        function list=pGetAnalyzisOrderList(looper)
            list=looper.AnalyzisOrderList;
            if isempty(list)

                list=pDetermineAnalysisOrder(looper);
            end
        end

        function ind=pGetNextLoopInd(looper)

            ind=looper.CurrentEntryIndex;
            if ind<0

                return
            end
            list=looper.pGetAnalyzisOrderList;



            while ind<numel(list)
                ind=ind+1;

                candidateReference=looper.References(list(ind).index);
                if~candidateReference.isMissing


                    if candidateReference.isTestHarness&&...
                        ~isempty(candidateReference.internalHarnessPath)

                        return
                    end


                    if~exist(candidateReference.fullpath,'file')

                        [modelPath,modelName,modelExtension]=...
                        fileparts(candidateReference.fullpath);
                        if strcmp(modelExtension,'.mdl')
                            candidateReferenceSLX=fullfile(...
                            modelPath,[modelName,'.slx']);
                            if exist(candidateReferenceSLX,'file')

                                candidateReference.fullpath=candidateReferenceSLX;
                                looper.References(list(ind).index)=candidateReference;

                                return
                            end
                        end


                        candidateReference.isMissing=true;
                        looper.References(list(ind).index)=candidateReference;
                    else

                        return
                    end
                end
            end


            ind=-1;
        end

        function r=pCreateReference(looper,name,internalHarnessPath)




            if nargin>2&&~isempty(internalHarnessPath)


                parentModel=strtok(internalHarnessPath,'/');
                [fp,underMLRoot]=UpgradeAdvisor.UpgradeLooper.notUnderMLRoot(parentModel);
                if underMLRoot
                    r=[];
                    return
                end
                isSubSystemReference=false;
                isLibrary=false;
                isModel=true;
                isTestHarness=true;
                isMissing=false;
            else

                internalHarnessPath='';


                [~,name,~]=fileparts(name);





                if isInCurrentSession(looper,name)

                    r=[];
                    return
                end



                [fp,underMLRoot]=UpgradeAdvisor.UpgradeLooper.notUnderMLRoot(name);
                if underMLRoot
                    r=[];
                    return
                end
                if isempty(fp)

                    isMissing=true;
                    isModel=true;
                    isTestHarness=false;
                    isLibrary=false;
                    isSubSystemReference=false;
                else
                    isMissing=false;
                    if bdIsLoaded(name)
                        isModel=strcmp(get_param(name,'blockdiagramtype'),'model');
                        isSubSystemReference=strcmp(get_param(name,'blockdiagramtype'),'subsystem');
                        isLibrary=strcmp(get_param(name,'blockdiagramtype'),'library');
                        isTestHarness=strcmp(get_param(name,'IsHarness'),'on');
                    else
                        info=Simulink.MDLInfo(name);
                        isSubSystemReference=strcmp(info.BlockDiagramType,'Subsystem');
                        isLibrary=info.IsLibrary;
                        isModel=strcmp(info.BlockDiagramType,'Model');
                        isTestHarness=false;
                    end
                end
            end

            r=struct(...
            'name',name,...
            'fullpath',fp,...
            'isMissing',isMissing,...
            'isTestHarness',isTestHarness,...
            'internalHarnessPath',internalHarnessPath,...
            'isModel',isModel,...
            'isSubSystemReference',isSubSystemReference,...
            'isLibrary',isLibrary);
        end


        function pInitialise(looper)
            looper.RootModelIndex=-1;
            looper.References=[];
            looper.CurrentEntryIndex=-1;
            looper.AnalyzisOrderList=[];
            delete(looper.CleanUp);
            looper.CleanUp=[];
            looper.pResetCheckData();
        end

        function pResetCheckData(looper)
            looper.CheckData=containers.Map('KeyType','char','ValueType','any');
        end
    end

    methods(Static)
        function[fp,underMLRoot]=notUnderMLRoot(name)
            fp=i_whichNoThrow(name);

            underMLRoot=strncmp(fp,matlabroot,numel(matlabroot))||...
            contains(fp,'(');
        end

        function clearCurrentSession


            l=UpgradeAdvisor.UpgradeLooper;

            model=l.getCurrentModelName;
            l.clear;
            if isempty(model)


                return
            end

            if bdIsLoaded(model)
                try
                    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(model,'new',UpgradeAdvisor.UPGRADE_GROUP_ID);
                    ID=UpgradeAdvisor.UPGRADE_HIERARCHY_ID;
                    t=mdlAdvObj.getTaskObj(ID,'-type','CheckID');
                    kk=0;
                    while kk<numel(t)
                        kk=kk+1;
                        if strcmp(t{kk}.ParentObj.ID,...
                            UpgradeAdvisor.UPGRADE_GROUP_ID)
                            t{kk}.reset;
                            break
                        end
                    end
                catch E
                    warning(E.identifier,'%s',E.message)
                end
            end
        end
    end

end


function entry=i_new_entry(position,compile)
    entry=struct('index',position,'compile',compile);
end

function path=i_whichNoThrow(varargin)
    try
        path=builtin('which',varargin{:});
    catch E
        path='';
        warning(E.identifier,'%s',E.message);
    end
end
