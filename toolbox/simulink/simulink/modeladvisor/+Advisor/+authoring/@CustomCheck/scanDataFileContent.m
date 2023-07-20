


function scanDataFileContent(this,domObj)


    messageParentNode=domObj.getElementsByTagName('messages');

    if messageParentNode.getLength==1

        this.CheckOutputFormatting.parseMessageDOMNode(messageParentNode.item(0));
    end



    checkDataNode=domObj.getElementsByTagName('checkdata').item(0);


    topLevelConstraints=checkDataNode.getChildNodes;


    for n=0:topLevelConstraints.getLength-1
        if topLevelConstraints.item(n).getNodeType==1
            nodeName=char(topLevelConstraints.item(n).getNodeName);


            IDString=char(topLevelConstraints.item(n).getAttribute('id'));
            if isempty(IDString)
                IDString=char(matlab.lang.internal.uuid);
            else
                isUniqueID=this.checkConstraintID(IDString);
                if~isUniqueID
                    DAStudio.error('Advisor:engine:CCConstraintIDNotUnique',IDString);
                end
            end

            if any(strcmp(nodeName,{'PositiveBlockParameterConstraint',...
                'NegativeBlockParameterConstraint',...
                'PositiveBlockTypeConstraint',...
                'NegativeBlockTypeConstraint'}))
                this.addConstraint(Advisor.authoring.internal.generateConstraintObject(topLevelConstraints.item(n),IDString));
            elseif strcmp(nodeName,'CompositeConstraint')
                this.addCompositeConstraint(Advisor.authoring.CompositeConstraint(topLevelConstraints.item(n)));
            else
                if~strcmp(this.CheckType,'BlockConstraint')
                    this.addConstraint(Advisor.authoring.(nodeName)(topLevelConstraints.item(n),IDString));
                else
                    this.addConstraint(Advisor.authoring.internal.generateConstraintObject(topLevelConstraints.item(n),IDString));
                end
            end
        end
    end



    ids=this.Constraints.keys;
    for n=1:this.NumConstraints
        constraint=this.Constraints(ids{n});

        dependentConstraintIDs=constraint.getPreRequisiteConstraintIDs;

        for ni=1:length(dependentConstraintIDs)
            if~this.Constraints.isKey(dependentConstraintIDs{ni})
                DAStudio.error('Advisor:engine:CCPreRequisiteIDNotFound',...
                dependentConstraintIDs{ni},class(constraint));
            end
            constraint.addPreRequisiteConstraintObject(this.Constraints(dependentConstraintIDs{ni}));
        end
    end

end