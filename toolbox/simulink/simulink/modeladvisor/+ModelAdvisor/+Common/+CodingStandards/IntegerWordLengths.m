
classdef IntegerWordLengths<ModelAdvisor.Common.CodingStandards.Base

    methods(Access=public)

        function this=IntegerWordLengths(system,messagePrefix)
            this@ModelAdvisor.Common.CodingStandards.Base(...
            system,messagePrefix);
            this.flaggedObjects=struct(...
            'uuid',{},...
            'typeList',{});
        end

        function algorithm(this)

            removeOutOfScope=true;
            parsedOutput=...
            Advisor.RegisterCGIRInspectorResults.getInstance.parseCGIRResults(...
            'NODE_EMULATED_WORDLENGTH',removeOutOfScope,this.system);
            if isempty(parsedOutput)
                parsedOutput={};
            else
                parsedOutput=parsedOutput.tag;
            end

            numResults=numel(parsedOutput);
            sids=cell(numResults,1);
            types=cell(numResults,1);

            for i=1:numResults
                sids{i}=this.removeParentSIDs(parsedOutput{i}.sid);
                types{i}=parsedOutput{i}.info('EmulatedType');
            end

            [sids,~,i2]=unique(sids);
            typeList=cell(size(sids));
            for i=1:numel(sids)
                dataTypes=unique(types(i2==i));
                typeList{i}=dataTypes;
            end



            if get_param(this.rootSystem,'ProdBitPerChar')==8
                needFilter=false;
            else
                needFilter=true;
            end

            for i=1:numel(sids)
                thisSid=sids{i};
                thisTypes=typeList{i};
                if needFilter
                    thisTypes=this.filterTypes(thisSid,thisTypes);
                end
                if~isempty(thisTypes)
                    this.addFlaggedObject(thisSid,thisTypes);
                end
            end


        end

        function report(this)





            resultTable=ModelAdvisor.FormatTemplate('TableTemplate');
            resultTable.setCheckText(this.getMessage(...
            'CheckText'));
            resultTable.setColTitles({...
            this.getMessage(...
            'ResultTableHeader_Object'),...
            this.getMessage(...
            'ResultTableHeader_EmulatedType')});
            resultTable.setSubBar(false);

            for i=1:this.getNumFlaggedObjects()
                flaggedObject=this.getFlaggedObjects(i);
                col_1=flaggedObject.uuid;
                col_2=flaggedObject.typeList{1};
                for j=2:numel(flaggedObject.typeList)
                    col_2=[col_2,', ',flaggedObject.typeList{j}];%#ok<AGROW>
                end
                resultTable.addRow({col_1,col_2});
            end

            if this.getNumFlaggedObjects()==0
                this.localResultStatus=true;
                resultTable.setSubResultStatus('pass');
                resultTable.setSubResultStatusText(this.getMessage(...
                'SubResultStatusText_Pass'));
            else
                this.localResultStatus=false;
                resultTable.setSubResultStatus('warn');
                resultTable.setSubResultStatusText(this.getMessage(...
                'SubResultStatusText_Warn'));
                resultTable.setRecAction(this.getMessage(...
                'RecAction'));
            end

            this.addReportObject(resultTable);

        end

    end

    methods(Access=protected)

        function addFlaggedObject(this,uuid,typeList)
            temp.uuid=uuid;
            temp.typeList=typeList;
            this.flaggedObjects(end+1)=temp;
        end

        function sidsOut=removeParentSIDs(~,sidsIn)
            if numel(sidsIn)==1
                s=sidsIn.Content;
            else
                s=sidsIn(1).Content;
            end


            handle=Simulink.ID.getHandle(s);
            sidsOut=Simulink.ID.getSID(handle);
        end

        function types=filterTypes(~,sid,oldTypes)
            isUint8=strcmp(oldTypes,'uint8');
            removeUint8=false;
            if any(isUint8)
                handle=Simulink.ID.getHandle(sid);
                switch class(handle)
                case 'double'
                    isSf=slprivate('is_stateflow_based_block',handle);
                    if isSf
                        object=get_param(handle,'Object');
                        states=object.find('-isa','Stateflow.State');
                        if~isempty(states)
                            removeUint8=true;
                        end
                    end
                case 'Stateflow.State'
                    removeUint8=true;
                case 'Stateflow.SimulinkBasedState'
                    removeUint8=true;
                case 'Stateflow.Transition'
                    theParent=handle.getParent();
                    states=theParent.find('-isa','Stateflow.State');
                    if~isempty(states)
                        removeUint8=true;
                    end
                case 'Stateflow.Junction'
                    if strcmp(handle.Type,'HISTORY')
                        removeUint8=true;
                    else
                        theParent=handle.getParent();
                        states=theParent.find('-isa','Stateflow.State');
                        if~isempty(states)
                            removeUint8=true;
                        end
                    end
                otherwise
                end
            end

            if removeUint8
                types=oldTypes(~isUint8);
            else
                types=oldTypes;
            end

        end

    end

end

