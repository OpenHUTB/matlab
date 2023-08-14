function removeModel(this,mdlName)






    modelIndex=find(strcmp(mdlName,this.modelList),1);
    if~isempty(modelIndex)
        modelIndex=modelIndex(1);
        this.modelLegendState(modelIndex)=[];

        if(length(this.legendBlockInfo)>=modelIndex)
            this.legendBlockInfo(modelIndex)=[];
        end
    end



    if(~isempty(modelIndex))
        this.modelList(modelIndex)='';
        this.removeSpreadSheetSourceObj(mdlName);
        closeIndex=[];
        for indexVarTs=1:length(this.expandedVarTs)
            if(this.expandedVarTs{indexVarTs}(1)==modelIndex)
                closeIndex=[closeIndex,indexVarTs];%#ok this variable cannot be preallocated.       
            end
        end
        this.expandedVarTs(closeIndex)=[];



        if(~isempty(this.hilitedVarTsBlks)&&...
            this.hilitedVarTsBlks{1}{1}==modelIndex)

            for index=1:length(this.hilitedVarTsBlks)
                blockPath=this.hilitedVarTsBlks{index}{3};
                posSep=strfind(blockPath,'/');
                if(~isempty(posSep))
                    bdname=blockPath(1:posSep(1)-1);
                    if(bdIsLoaded(bdname))
                        try
                            hilite_system(this.hilitedVarTsBlks{index}{3},'none');
                        catch
                        end
                    end
                end
            end

            this.hilitedVarTsBlks={};
        else


            for index=length(this.hilitedVarTsBlks):-1:1
                blockPath=this.hilitedVarTsBlks{index}{3};
                posSep=strfind(blockPath,'/');
                if(~isempty(posSep))
                    bdname=blockPath(1:posSep(1)-1);
                    findIndex=strcmp(bdname,this.modelList);
                    if(this.hilitedVarTsBlks{index}{1}==findIndex)
                        this.hilitedVarTsBlks(index)=[];
                    end
                end
            end
        end
        if(length(this.hasExpandedVarTs)>=modelIndex)
            this.hasExpandedVarTs(modelIndex)=[];
        end
        if(~isempty(this.modelList))
            if(strcmp(this.modelName,mdlName))
                this.modelName=this.modelList{1};
            end
            mdlIdx=strmatch(this.modelName,...
            this.modelList,'exact');
            this.currentTabIndex=mdlIdx(end)-1;
        end

        if(~isempty(this.legendDlg))
            if(isempty(this.modelList))

                delete(this.legendDlg)
                this.legendDlg={};
            else


                this.legendDlg.refresh
            end
        end
    end


