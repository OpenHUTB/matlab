classdef CompositeConstraint<handle






















































    properties
        CompositeOperator;
    end

    properties(SetAccess=private)
        ConstraintIDs={};
    end

    properties(Access=private)
        ConstraintHandles={};
    end

    methods

        function this=CompositeConstraint(varargin)

            if nargin==1&&(isa(varargin{1},'matlab.io.xml.dom.Element'))
                this.scanDOMNode(varargin{1});

            elseif(nargin>1)
                DAStudio.error('Advisor:engine:UnsupportedMethodInput','CompositeConstraint');
            end
        end


        function set.CompositeOperator(this,opp)
            if any(strcmpi({'and','or'},opp))
                this.CompositeOperator=opp;
            else
                DAStudio.error('Advisor:engine:InvalidCompositeOpp',opp);
            end
        end


        function opperator=getCompositeOperator(this)
            opperator=this.CompositeOperator;
        end


        function idcell=getConstraintIDs(this)
            idcell=this.ConstraintIDs;
        end


        function addConstraintID(this,ConstraintID)

            if~ischar(ConstraintID)
                DAStudio.error('Advisor:engine:UnsupportedMethodInput','addConstraintID');
            end

            this.ConstraintIDs{end+1}=ConstraintID;
        end


        function out=getConstraintObjects(this)
            out=this.ConstraintHandles;
        end


        function[ResultStatus,constrResultData]=check(this,system)
            compositeOperator=this.getCompositeOperator();
            constraintsInComposite=this.getConstraintObjects();

            ResultStatus=true;


            allBlocksInThisSystem=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all');
            blocksToCheck=setdiff(allBlocksInThisSystem,system);

            myMap=containers.Map();
            for i=1:numel(blocksToCheck)
                for j=1:numel(constraintsInComposite)
                    currentConstraint=constraintsInComposite{j};
                    BlockChecked=true;
                    if isa(currentConstraint,'Advisor.authoring.BlockParameterConstraint')
                        ConstraintBlkType=currentConstraint.BlockType;
                        if strcmp(get_param(blocksToCheck{i},'BlockType'),ConstraintBlkType)
                            [tempResultStatus1,tempResultData1,~,prerequisiteStatusArray,prerequisiteData]=Advisor.authoring.internal.checkBlockConstraint(blocksToCheck{i},system,currentConstraint);
                            if any(prerequisiteStatusArray==false)
                                tempResultStatus1=true;
                            end
                        else
                            tempResultStatus1=true;
                            BlockChecked=false;
                        end
                    elseif isa(currentConstraint,'Advisor.authoring.internal.ModelParameterConstraint')
                        DAStudio.error('Advisor:engine:InvalidRootConstraint',class(currentConstraint));
                    elseif isa(currentConstraint,'Advisor.authoring.BlockTypeConstraint')
                        [tempResultStatus1,tempResultData1,~,prerequisiteStatusArray,prerequisiteData]=Advisor.authoring.internal.checkBlockConstraint(blocksToCheck{i},system,currentConstraint);
                        if any(prerequisiteStatusArray==false)
                            tempResultStatus1=true;
                        end
                    end

                    if strcmpi(compositeOperator,'and')
                        ResultStatus=ResultStatus&&tempResultStatus1;
                    elseif strcmpi(compositeOperator,'or')
                        ResultStatus=ResultStatus||tempResultStatus1;
                    end

                    if BlockChecked&&any(prerequisiteStatusArray==false)
                        tempResultData1={'Prerequisite not met'};
                    end

                    if~tempResultStatus1||(BlockChecked&&any(prerequisiteStatusArray==false))
                        if~any(strcmp(myMap.keys,currentConstraint.ID))
                            myMap(currentConstraint.ID)=[Simulink.ID.getSID(blocksToCheck{i}),tempResultData1];
                        else
                            tempResultData=myMap(currentConstraint.ID);
                            tempResultData=[tempResultData;[Simulink.ID.getSID(blocksToCheck{i}),tempResultData1]];
                            myMap(currentConstraint.ID)=tempResultData;
                        end

                        for prerequisiteIndex=1:numel(prerequisiteData)
                            if~any(strcmp(myMap.keys,prerequisiteData{prerequisiteIndex}.ID))
                                myMap(prerequisiteData{prerequisiteIndex}.ID)=[Simulink.ID.getSID(blocksToCheck{i}),prerequisiteData{prerequisiteIndex}.Data];
                            else
                                tempResultData=myMap(prerequisiteData{prerequisiteIndex}.ID);
                                tempResultData=[tempResultData;[Simulink.ID.getSID(blocksToCheck{i}),prerequisiteData{prerequisiteIndex}.Data]];
                                myMap(prerequisiteData{prerequisiteIndex}.ID)=tempResultData;
                            end
                        end
                    end
                end
            end

            constrResultData=myMap;
        end

    end

    methods(Hidden=true)

        function scanDOMNode(this,constraintNode)

            childNodes=constraintNode.getChildNodes;

            for n=0:childNodes.getLength-1

                if childNodes.item(n).getNodeType==1
                    nodeName=char(childNodes.item(n).getNodeName);
                    switch nodeName
                    case 'ID'

                        this.addConstraintID(Advisor.authoring.internal.getXMLNodeTextContent(childNodes.item(n)));
                    case 'operator'

                        this.CompositeOperator=Advisor.authoring.internal.getXMLNodeTextContent(childNodes.item(n));
                    otherwise
                        DAStudio.error('Advisor:engine:CCUnknownXMLNode',nodeName);
                    end
                end
            end
        end

        function[constraintNode]=getXMLNode(this,doc)
            constraintNode=doc.createElement('CompositeConstraint');
            if~isempty(this.ConstraintIDs)
                for n=1:length(this.ConstraintIDs)
                    dependsOnNode=doc.createElement('ID');
                    dependsOnNode.setTextContent(this.ConstraintIDs{n});
                    constraintNode.appendChild(dependsOnNode);
                end
            end

            operaterNode=doc.createElement('operator');
            operaterNode.setTextContent(this.CompositeOperator);
            constraintNode.appendChild(operaterNode);
        end


        function addConstraintObject(this,handle)
            if isa(handle,'Advisor.authoring.internal.Constraint')
                this.ConstraintHandles{end+1}=handle;
            else
                DAStudio.error('Advisor:engine:UnsupportedMethodInput','addConstraintObject');
            end
        end


        function setConstraintIDs(this,ids)
            if~iscellstr(ids)
                DAStudio.error('Advisor:engine:UnsupportedMethodInput','setConstraintIDs');
            end

            for n=1:length(ids)
                this.addConstraintID(ids{n});
            end
        end
    end
end

