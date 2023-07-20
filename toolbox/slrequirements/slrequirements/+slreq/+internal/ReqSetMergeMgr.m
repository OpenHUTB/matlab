classdef ReqSetMergeMgr<handle






    properties(Access=private)
        mAllWorkers=containers.Map;
    end


    methods(Access=private)
        function this=ReqSetMergeMgr()
            this.init();
        end

        function this=init(this)
            this.mAllWorkers=containers.Map('KeyType','char','ValueType','any');
        end

        function reset(this)
            clear(this.mAllWorkers);
        end
    end


    methods(Access=private)
        function tf=isWorker(this,tempFilename)
            tf=this.mAllWorkers.isKey(tempFilename);
        end

        function setWorker(this,tempFilename,worker)
            this.mAllWorkers(tempFilename)=worker;
        end

        function worker=getWorker(this,tempFilename)
            worker=this.mAllWorkers(tempFilename);
        end

        function removeWorker(this,tempFilename)
            this.mAllWorkers.remove(tempFilename);
        end

    end


    methods(Static)
        function singleton=getInstance(doInit)
            mlock;
            persistent reqSetMergeMgr;
            if isempty(reqSetMergeMgr)||~isvalid(reqSetMergeMgr)
                if nargin==0||doInit
                    reqSetMergeMgr=slreq.internal.ReqSetMergeMgr;
                end
            end
            singleton=reqSetMergeMgr;
        end

        function tf=exists()
            instance=slreq.internal.ReqSetMergeMgr.getInstance(false);
            tf=~isempty(instance);
        end
    end


    methods(Static)
        function destFullFilepath=startOperation(tempDirname,srcFullFilepath)


            [~,srcFileMainPart,srcFileExtPart]=fileparts(srcFullFilepath);
            srcNewFileMainPart=strcat(srcFileMainPart,'-merged',srcFileExtPart);
            destFullFilepath=fullfile(tempDirname,srcNewFileMainPart);
            copied=copyfile(srcFullFilepath,destFullFilepath);
            if(copied)
                instance=slreq.internal.ReqSetMergeMgr.getInstance();
                if~isempty(instance)
                    if~instance.isWorker(destFullFilepath)
                        worker=slreq.internal.ReqSetMergeWorker(destFullFilepath);
                        instance.setWorker(destFullFilepath,worker);
                    end
                else
                    destFullFilepath='';
                end
            else

                destFullFilepath='';
            end
        end

        function done=discardOperation(tempFullFilepath)
            done=slreq.internal.ReqSetMergeMgr.doLastOperation(tempFullFilepath,false,'');
        end

        function done=finishOperation(tempFullFilepath,destFullFilepath)
            done=slreq.internal.ReqSetMergeMgr.doLastOperation(tempFullFilepath,true,destFullFilepath);
        end
    end


    methods(Static)

        function doMergeNode(mergeData,~)
            import com.mathworks.toolbox.rptgenxmlcomp.comparison.merge.*;
            import com.mathworks.toolbox.rptgenxmlcomp.comparison.util.*;
            import com.mathworks.toolbox.rptgenxmlcomp.comparison.node.*;

            sourceComparisonSource=mergeData.getSourceComparisonSource();
            targetComparisonSource=mergeData.getTargetComparisonSource();

            difference=mergeData.getDifference();

            sourceReqSetFileName=char(sourceComparisonSource.getParentSource().toString());
            mergedReqSetFileName=char(targetComparisonSource.toString());




            sourceSnippet=difference.getSnippet(sourceComparisonSource);
            targetSnippet=difference.getTargetSnippet();

            if~isempty(sourceSnippet)
                sourceReqSID=char(sourceSnippet.getParameter('RequirementSID').getValue());
                slreq.internal.ReqSetMergeMgr.addRequirement(mergedReqSetFileName,sourceReqSetFileName,str2double(sourceReqSID));
            end

            if~isempty(targetSnippet)
                targetReqSID=char(targetSnippet.getParameter('RequirementSID').getValue());
                slreq.internal.ReqSetMergeMgr.removeRequirement(mergedReqSetFileName,str2double(targetReqSID));
            end

        end

        function doMergeNodeParameter(mergeData,mergeParameters,~,~)

            import com.mathworks.toolbox.rptgenxmlcomp.comparison.merge.*;
            import com.mathworks.toolbox.rptgenxmlcomp.comparison.util.*;
            import com.mathworks.toolbox.rptgenxmlcomp.comparison.node.*;

            sourceComparisonSource=mergeData.getSourceComparisonSource();
            targetComparisonSource=mergeData.getTargetComparisonSource();

            difference=mergeData.getDifference();

            sourceReqSetFileName=char(sourceComparisonSource.getParentSource().toString());
            mergedReqSetFileName=char(targetComparisonSource.toString());

            sourceSnippet=difference.getSnippet(sourceComparisonSource);
            if isempty(sourceSnippet)

                return
            end
            sourceReqSID=char(sourceSnippet.getParameter('RequirementSID').getValue());
            sourceReqParam=char(mergeParameters.getFirst().getTagName());

            if~isempty(sourceReqSID)&&~isempty(sourceReqParam)
                slreq.internal.ReqSetMergeMgr.addRequirementParameter(mergedReqSetFileName,sourceReqSetFileName,sourceReqSID,sourceReqParam);
            end

        end

    end


    methods(Static,Hidden)

        function done=addRequirement(tempFullFilename,srcFullFilename,srcSID)
            done=false;
            instance=slreq.internal.ReqSetMergeMgr.getInstance();
            if~isempty(instance)
                if instance.isWorker(tempFullFilename)
                    worker=instance.getWorker(tempFullFilename);
                    if~isempty(worker)
                        done=worker.copyRequirement(srcFullFilename,srcSID);
                    end
                end
            end
        end

        function done=removeRequirement(tempFullFilename,tempSID)


            done=false;
            instance=slreq.internal.ReqSetMergeMgr.getInstance();
            if~isempty(instance)
                if instance.isWorker(tempFullFilename)
                    worker=instance.getWorker(tempFullFilename);
                    if~isempty(worker)
                        done=worker.removeRequirement(tempSID);
                    end
                end
            end
        end

        function obj=addRequirementParameter(tempFullFilename,srcFullFilename,srcSID,srcParamKey)










            tempReqObj=slreq.utils.getReqObjFromArtifactID(tempFullFilename,srcSID);
            srcReqObj=slreq.utils.getReqObjFromArtifactID(srcFullFilename,srcSID);

            if and(~isempty(tempReqObj),~isempty(srcReqObj))
                obj=1;
                tempReqObj.(srcParamKey)=srcReqObj.(srcParamKey);
            else
                obj=0;
            end
        end

        function done=doLastOperation(tempFullFilepath,save,destFullFilepath)

            instance=slreq.internal.ReqSetMergeMgr.getInstance();
            if~isempty(instance)
                if instance.isWorker(tempFullFilepath)
                    worker=instance.getWorker(tempFullFilepath);

                    if~isempty(worker)
                        if save

                            worker.save();
                        end
                        worker.delete();
                    end


                    instance.removeWorker(tempFullFilepath);
                end
            end


            if save

                done=movefile(tempFullFilepath,destFullFilepath);
            else

                delete(tempFullFilepath);
                done=true;
            end

        end
    end

end

