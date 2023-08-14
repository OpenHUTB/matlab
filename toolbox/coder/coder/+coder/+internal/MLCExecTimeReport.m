classdef MLCExecTimeReport<coder.profile.ExecTimeReport



    methods(Access=public,Static=true)

        function modelHighlight(varargin)

            entitiesToHighlight=varargin;

            for i=1:length(entitiesToHighlight)
                entity=entitiesToHighlight{i};

                fcn=entity;
                if exist(fcn,'file')



                    matlab.desktop.editor.openAndGoToLine(which(fcn),1);
                else
                    delimiter=find(entity==':',1,'last');
                    valdiLink=false;
                    if~isempty(delimiter)
                        pos=entity((delimiter+1):end);
                        filename=entity(1:(delimiter-1));
                        if exist(filename,'file')
                            positions=strsplit(pos,'-');
                            position_start=positions{1};
                            h=matlab.desktop.editor.openDocument(filename);
                            index=str2double(position_start);
                            if isnumeric(index)
                                valdiLink=true;
                                line=matlab.desktop.editor.indexToPositionInLine(h,index);
                                matlab.desktop.editor.openAndGoToLine(filename,line);
                            end
                        end
                    end
                    if~valdiLink
                        error(message('CoderProfile:ExecutionTime:ProfilingBDRefNotValid'));
                    end
                end
            end
        end

        function url=codeHighlight(componentName,buildDir,varargin)
            try
                url=coder.internal.slcoderReport('hiliteCode',buildDir,varargin{:});
            catch e
                if strcmp(e.identifier,'RTW:report:ReportNotFound')
                    id='CoderProfile:ExecutionTime:ProfilingMissingHtmlReport';
                    msg=message(id,componentName).getString;
                    eNew=MException(id,msg);
                    eNew=eNew.addCause(e);
                    throw(eNew)
                else
                    rethrow(e)
                end
            end
        end

        function[execProfBaseStr,execProfFullStr,execProfileObjFunction]=searchForExecProfObj(~,modelName)

            execProfBaseStr=[];
            execProfFullStr=[];
            execProfileObjFunction=[];


            MATLABStoreContents=getCoderExecutionProfile(modelName);
            if~isempty(MATLABStoreContents)
                execProfBaseStr=sprintf('getCoderExecutionProfile(''%s'')',modelName);
                execProfFullStr='executionProfile';
                execProfileObjFunction=execProfBaseStr;
            end
        end

        function[execProfBaseStr,execProfFullStr,execProfileObjFunction]=searchForStackProfObj(~,modelName)
            execProfBaseStr=[];
            execProfFullStr=[];
            execProfileObjFunction=[];


            MATLABStoreContents=getCoderStackProfile(modelName);
            if~isempty(MATLABStoreContents)
                execProfBaseStr=sprintf('getCoderStackProfile(''%s'')',modelName);
                execProfFullStr=execProfBaseStr;
                execProfileObjFunction=execProfBaseStr;
            end
        end

        function[modelText,entitiesToHighlight]=getTaskTextandEntity(traceInfo,~)


            modelText=traceInfo.getName;
            if exist(modelText,'file')


                entitiesToHighlight={modelText};
            else

                if exist(traceInfo.getOriginalModelRef,'file')
                    entitiesToHighlight={traceInfo.getOriginalModelRef};
                else



                    entitiesToHighlight={''};
                end
            end
        end
    end
end
