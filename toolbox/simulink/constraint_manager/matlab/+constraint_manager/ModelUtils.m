classdef ModelUtils

    methods(Static)

        function maskContext=getMaskContext(mf0Model,blockHandle)
            maskContext=simulink.constraintmanager.MaskContext(mf0Model,struct('blockHandle',blockHandle));
        end

        function sharedContext=getSharedContext(mf0Model,product,matFileName,matFilePath)
            sharedContext=simulink.constraintmanager.SharedContext(mf0Model,...
            struct('product',product,...
            'matfilename',matFileName,...
            'matfilepath',matFilePath));
        end


        function constraint=getParameterConstraintModelObj(mf0Model,constraintId,constraintObj,constraintContext)

            constraint=simulink.constraintmanager.Constraint(mf0Model,struct('id',constraintId,...
            'name',constraintObj.Name,'type','ParameterConstraint',...
            'isModified',false));

            constraint.context=constraintContext;

            parameterConstraint=simulink.constraintmanager.ParameterConstraint(mf0Model);

            constraintRulesArray=constraintObj.ConstraintRules;


            for i=1:length(constraintRulesArray)

                constraintRule=simulink.constraintmanager.ParameterConstraintRule(mf0Model);
                constraintRuleObj=constraintRulesArray(i);

                constraintRule.id='ParameterRule-'+string(i);
                constraintRule.name='ParameterRule-'+string(i);

                for i=1:length(constraintRuleObj.DataTypes)
                    if contains(constraintRuleObj.DataTypes{i},'enum')
                        constraintRule.datatypes.add('enum');
                        enumString=constraintRuleObj.DataTypes{i};
                        openBracket=strfind(enumString,'(');
                        closeBracket=strfind(enumString,')');
                        constraintRule.enumClassName=enumString(openBracket+1:closeBracket-1);
                    else
                        constraintRule.datatypes.add(constraintRuleObj.DataTypes{i});
                    end
                end

                for i=1:length(constraintRuleObj.Fraction)
                    constraintRule.fraction.add(constraintRuleObj.Fraction{i});
                end
                for i=1:length(constraintRuleObj.Complexity)
                    constraintRule.complexity.add(constraintRuleObj.Complexity{i});
                end
                for i=1:length(constraintRuleObj.Dimension)
                    constraintRule.dimension.add(constraintRuleObj.Dimension{i});
                end
                for i=1:length(constraintRuleObj.Sign)
                    constraintRule.sign.add(constraintRuleObj.Sign{i});
                end
                for i=1:length(constraintRuleObj.Finiteness)
                    constraintRule.finiteness.add(constraintRuleObj.Finiteness{i});
                end

                constraintRule.minimum=constraintRuleObj.Minimum;
                constraintRule.maximum=constraintRuleObj.Maximum;

                customConstraint=simulink.constraintmanager.CustomConstraint(mf0Model);
                customConstraint.MATLABExpression=constraintRuleObj.CustomConstraint;
                customConstraint.errorMessage=constraintRuleObj.CustomErrorMessage;

                constraintRule.customConstraint=customConstraint;

                parameterConstraint.constraintRules.add(constraintRule);

                parameterConstraint.constraintRules.add(constraintRule);
            end

            constraint.constraintDetail=parameterConstraint;
        end

        function populateFixedpointConstraint(fixedpointconstraint,dataType)
            fixedpointTypeObject=eval(dataType);
            fixedpointconstraint.signedness=fixedpointTypeObject.Signedness;
            fixedpointconstraint.wordlength=string(fixedpointTypeObject.WordLength);
            if contains(fixedpointTypeObject.DataTypeMode,'slope and bias')
                fixedpointconstraint.scaling='slope and bias';
                fixedpointconstraint.slope=string(fixedpointTypeObject.Slope);
                fixedpointconstraint.bias=string(fixedpointTypeObject.Bias);
            else
                fixedpointconstraint.scaling='binary point';
                fixedpointconstraint.fractionlength=string(fixedpointTypeObject.FractionLength);
            end
        end



        function constraint=getCrossParameterConstraintModelObj(mf0Model,constraintId,constraintObj,constraintContext)

            constraint=simulink.constraintmanager.Constraint(mf0Model,struct('id',constraintId,...
            'name',constraintObj.Name,'type','CrossParameterConstraint',...
            'isModified',false));
            constraint.context=constraintContext;

            crossParameterConstraint=simulink.constraintmanager.CrossParameterConstraint(mf0Model);

            customConstraint=simulink.constraintmanager.CustomConstraint(mf0Model);
            customConstraint.MATLABExpression=constraintObj.MATLABexpression;
            customConstraint.errorMessage=constraintObj.ErrorMessage;

            crossParameterConstraint.customConstraint=customConstraint;

            constraint.constraintDetail=crossParameterConstraint;
        end

        function constraint=getPortConstraintModelObj(mf0Model,constraintId,constraintObj,constraintContext)

            constraint=simulink.constraintmanager.Constraint(mf0Model,...
            struct('id',constraintId,...
            'name',constraintObj.Name,...
            'type','PortConstraint','isModified',false));

            constraint.context=constraintContext;

            portConstraint=simulink.constraintmanager.PortConstraint(mf0Model);


            for i=1:length(constraintObj.ParameterConditions)
                parameterCondition=simulink.constraintmanager.ParameterCondition(mf0Model);
                paramCondition=constraintObj.ParameterConditions(i);
                parameterCondition.name=paramCondition.Name;
                for j=1:length(paramCondition.Values)
                    parameterCondition.values.add(paramCondition.Values{j});
                end
                portConstraint.parameterConditions.add(parameterCondition);
            end


            rule=simulink.constraintmanager.PortConstraintRule(mf0Model);
            for j=1:length(constraintObj.Rule.DataType)
                rule.datatype.add(constraintObj.Rule.DataType{j});
            end
            for j=1:length(constraintObj.Rule.Dimension)
                rule.dimension.add(constraintObj.Rule.Dimension{j});
            end
            for j=1:length(constraintObj.Rule.Complexity)
                rule.complexity.add(constraintObj.Rule.Complexity{j});
            end

            fixedpointconstraint=constraintObj.Rule.FixedPointConstraint;
            rule.fixedpointconstraint=simulink.constraintmanager.FixedpointConstraint(mf0Model,...
            struct('signedness',fixedpointconstraint.Signedness,...
            'wordlength',fixedpointconstraint.WordLength,...
            'scaling',fixedpointconstraint.Scaling,...
            'bias',fixedpointconstraint.Bias));

            portConstraint.rule=rule;

            portConstraint.diagnosticLevel=constraintObj.DiagnosticLevel;
            portConstraint.diagnosticMessage=constraintObj.DiagnosticMessage;

            constraint.constraintDetail=portConstraint;
        end

        function constraint=getCrossPortConstraintModelObj(mf0Model,constraintManagerModelObject,constraintId,constraintObj,constraintContext)

            constraint=simulink.constraintmanager.Constraint(mf0Model,...
            struct('id',constraintId,...
            'name',constraintObj.Name,...
            'type','CrossPortConstraint','isModified',false));

            constraint.context=constraintContext;

            crossPortConstraint=simulink.constraintmanager.CrossPortConstraint(mf0Model);


            for i=1:length(constraintObj.ParameterConditions)
                parameterCondition=simulink.constraintmanager.ParameterCondition(mf0Model);
                paramCondition=constraintObj.ParameterConditions(i);
                parameterCondition.name=paramCondition.Name;
                for j=1:length(paramCondition.Values)
                    parameterCondition.values.add(paramCondition.Values{j});
                end
                crossPortConstraint.parameterConditions.add(parameterCondition);
            end

            if constraintObj.Rule==""
                crossPortConstraint.rule='NoRule';
            else
                crossPortConstraint.rule=constraintObj.Rule;
            end

            associations=constraintObj.Associations;
            associationsIds=cellfun(@(a)constraint_manager.ModelUtils.getPortIdentifierId...
            (constraintManagerModelObject,a),associations,...
            'UniformOutput',false);
            for k=1:length(associationsIds)
                crossPortConstraint.associations.add(associationsIds{k});
            end

            crossPortConstraint.diagnosticLevel=constraintObj.DiagnosticLevel;
            crossPortConstraint.diagnosticMessage=constraintObj.DiagnosticMessage;

            constraint.constraintDetail=crossPortConstraint;
        end

        function MATFileObj=getMATFileModelObject(mf0Model,matFileId,product,matFileName,matFilePath)
            MATFileObj=simulink.constraintmanager.MATFile(mf0Model,struct('id',matFileId));
            MATFileObj.context=constraint_manager.ModelUtils.getSharedContext(mf0Model,product,matFileName,matFilePath);
        end

        function parameterConstraint=createParameterConstraintObject(dataModelObj)
            parameterConstraint=Simulink.Mask.Constraints;
            constraintData=dataModelObj.constraintDetail;
            parameterConstraint.Name=dataModelObj.name;

            dataModelRuleObjs=constraintData.constraintRules;

            for i=1:dataModelRuleObjs.Size
                dataModelRuleObj=dataModelRuleObjs(i);
                customConstraintObj=dataModelRuleObj.customConstraint;

                dataTypes=dataModelRuleObj.datatypes.toArray;
                if(any(contains(dataTypes,'enum')))
                    enumStr=['enum(',dataModelRuleObj.enumClassName,')'];
                    dataTypes=strrep(dataTypes,'enum',enumStr);
                end

                parameterConstraint.addParameterConstraintRule('DataTypes',dataTypes,...
                'Fraction',dataModelRuleObj.fraction.toArray,...
                'Complexity',dataModelRuleObj.complexity.toArray,...
                'Dimension',dataModelRuleObj.dimension.toArray,...
                'Sign',dataModelRuleObj.sign.toArray,'Finiteness',dataModelRuleObj.finiteness.toArray,...
                'Minimum',dataModelRuleObj.minimum,'Maximum',dataModelRuleObj.maximum,...
                'CustomConstraint',customConstraintObj.MATLABExpression,...
                'CustomErrorMessage',customConstraintObj.errorMessage);
            end
        end

        function fixdtString=getFixdtStringFromObject(ruleObj)
            fixdtString='fixdt(';
            fixedpointconstraint=ruleObj.fixedpointconstraint;
            if strcmp(fixedpointconstraint.signedness,'Signed')
                fixdtString=append(fixdtString,'1,');
            else
                fixdtString=append(fixdtString,'0,');
            end

            fixdtString=append(fixdtString,[fixedpointconstraint.wordlength,',']);

            if strcmp(fixedpointconstraint.scaling,'binary point')
                fixdtString=append(fixdtString,fixedpointconstraint.fractionlength);
            else
                fixdtString=append(fixdtString,[fixedpointconstraint.slope,',']);
                fixdtString=append(fixdtString,fixedpointconstraint.bias);
            end
            fixdtString=append(fixdtString,')');


            try
                fixedpoint=eval(fixdtString);
            catch exp
                error('Wrong fixdt String formed');
            end
        end

        function crossparameterConstraint=createCrossParameterConstraintObject(dataModelObj)
            crossparameterConstraint=Simulink.Mask.CrossParameterConstraints;
            crossparameterConstraint.Name=dataModelObj.name;
            constraintData=dataModelObj.constraintDetail;

            customConstraintObj=constraintData.customConstraint;

            if~isempty(customConstraintObj.MATLABExpression)
                crossparameterConstraint.MATLABexpression=customConstraintObj.MATLABExpression;
            end
            if~isempty(customConstraintObj.errorMessage)
                crossparameterConstraint.ErrorMessage=customConstraintObj.errorMessage;
            end
        end

        function portConstraint=createPortConstraintObject(dataModelObj)
            portConstraint=Simulink.Mask.PortConstraint;
            portConstraint.Name=dataModelObj.name;
            constraintData=dataModelObj.constraintDetail;

            parameterConditions=constraintData.parameterConditions.toArray;
            for i=1:length(parameterConditions)
                portConstraint.addParameterCondition('Name',parameterConditions(i).name,...
                'Values',parameterConditions(i).values.toArray);
            end

            dataModelRuleObj=constraintData.rule;
            rule=Simulink.Mask.PortConstraintRule;

            if~isempty(dataModelRuleObj.datatype)
                rule.DataType=dataModelRuleObj.datatype.toArray;
                if any(contains(rule.DataType,'fixedpoint'))
                    fixedpointconstraint=rule.FixedPointConstraint;
                    fixedpointconstraint.Signedness=dataModelRuleObj.fixedpointconstraint.signedness;
                    fixedpointconstraint.WordLength=dataModelRuleObj.fixedpointconstraint.wordlength;
                    fixedpointconstraint.Scaling=dataModelRuleObj.fixedpointconstraint.scaling;
                    fixedpointconstraint.Bias=dataModelRuleObj.fixedpointconstraint.bias;
                end
            end
            if~isempty(dataModelRuleObj.complexity)
                rule.Complexity=dataModelRuleObj.complexity.toArray;
            end
            if~isempty(dataModelRuleObj.dimension)
                rule.Dimension=dataModelRuleObj.dimension.toArray;
            end
            portConstraint.setRule(rule);

            if~isempty(constraintData.diagnosticLevel)
                portConstraint.DiagnosticLevel=constraintData.diagnosticLevel;
            end
            if~isempty(constraintData.diagnosticMessage)
                portConstraint.DiagnosticMessage=constraintData.diagnosticMessage;
            end
        end

        function crossPortConstraint=createCrossPortConstraintObject(dataModelObj,constraintObj)
            crossPortConstraint=Simulink.Mask.CrossPortConstraint;
            crossPortConstraint.Name=constraintObj.name;
            constraintData=constraintObj.constraintDetail;

            parameterConditions=constraintData.parameterConditions.toArray;
            pcArray=Simulink.Mask.ParameterCondition.empty(0,length(parameterConditions));
            for i=1:length(parameterConditions)
                pc=Simulink.Mask.ParameterCondition;
                pc.Name=parameterConditions(i).name;
                pc.Values=parameterConditions(i).values.toArray;
                pcArray(i)=pc;
            end
            if~isempty(pcArray)
                crossPortConstraint.ParameterConditions=pcArray;
            end

            if constraintData.rule=="NoRule"
                crossPortConstraint.Rule='';
            else
                crossPortConstraint.Rule=string(constraintData.rule);
            end

            associationIds=constraintData.associations.toArray;
            associationNames=cellfun(@(a)constraint_manager.ModelUtils.getPortIdentifierName...
            (dataModelObj,a),associationIds,'UniformOutput',false);

            if~isempty(associationNames)
                crossPortConstraint.Associations=associationNames;
            end

            if~isempty(constraintData.diagnosticLevel)
                crossPortConstraint.DiagnosticLevel=constraintData.diagnosticLevel;
            end
            if~isempty(constraintData.diagnosticMessage)
                crossPortConstraint.DiagnosticMessage=constraintData.diagnosticMessage;
            end
        end

        function sharedContext=cloneSharedContext(mf0Model,sharedContext)
            sharedContext=simulink.constraintmanager.SharedContext(mf0Model,...
            struct('product',sharedContext.product,...
            'matfilename',sharedContext.matfilename,...
            'matfilepath',sharedContext.matfilepath));
        end

        function portConstraintId=getPortConstraintId(dataModelObj,portConstraintName)
            portConstraintId=[];
            allConstraints=dataModelObj.constraints;
            for i=1:allConstraints.Size
                if strcmp(allConstraints(i).type,'PortConstraint')&&strcmp(allConstraints(i).name,portConstraintName)
                    portConstraintId=allConstraints(i).id;
                    return;
                end
            end
        end

        function portConstraintName=getPortConstraintName(dataModelObj,portConstraintId)
            portConstraintName=[];
            allConstraints=dataModelObj.constraints;
            for i=1:allConstraints.Size
                if strcmp(allConstraints(i).type,'PortConstraint')&&strcmp(allConstraints(i).id,portConstraintId)
                    portConstraintName=allConstraints(i).name;
                    return;
                end
            end
        end

        function portIdentifierId=getPortIdentifierId(dataModelObj,portIdentifierName)
            portIdentifierId=[];
            allPortIdentifiers=dataModelObj.portIdentifiers;
            for i=1:allPortIdentifiers.Size
                if strcmp(allPortIdentifiers(i).name,portIdentifierName)
                    portIdentifierId=allPortIdentifiers(i).id;
                    return;
                end
            end
        end

        function portIdentifierName=getPortIdentifierName(dataModelObj,portIdentifierId)
            portIdentifierName=[];
            allPortIdentifiers=dataModelObj.portIdentifiers;
            for i=1:allPortIdentifiers.Size
                if strcmp(allPortIdentifiers(i).id,portIdentifierId)
                    portIdentifierName=allPortIdentifiers(i).name;
                    return;
                end
            end
        end


        function parameterConstraintId=getParameterConstraintId(dataModelObj,parameterConstraintName)
            parameterConstraintId=[];
            allConstraints=dataModelObj.constraints;
            for i=1:allConstraints.Size
                if strcmp(allConstraints(i).type,'ParameterConstraint')&&strcmp(allConstraints(i).name,parameterConstraintName)
                    parameterConstraintId=allConstraints(i).id;
                    return;
                end
            end
        end


        function parameterConstraintId=getSharedConstraintIdFromMATFile(dataModelObj,parameterConstraintName,matFileNameFromMask)
            parameterConstraintId='';
            allMATFiles=dataModelObj.MATFiles;
            for m=1:allMATFiles.Size
                if strcmp(allMATFiles(m).context.matfilename,matFileNameFromMask)
                    matFileConstraints=allMATFiles(m).matFileConstraints;
                    for i=1:matFileConstraints.Size
                        if strcmp(matFileConstraints(i).name,parameterConstraintName)
                            parameterConstraintId=matFileConstraints(i).id;
                            return;
                        end
                    end
                end
            end
        end

        function isFileLoadedInModel=tryLoadingAssociatedMATFileToModel(dataModelObj,matFileName,constraintManagerInterface)
            isFileLoadedInModel=false;
            allMATFiles=dataModelObj.MATFiles;
            for m=1:allMATFiles.Size
                if strcmp(allMATFiles(m).context.matfilename,matFileName)
                    isFileLoadedInModel=true;
                    return;
                end
            end
            try
                sharedConstraintList=constraint_manager.SharedConstraintsHelper.loadMATFileConstraints(matFileName);
                product='';
                matFilePath=constraint_manager.SharedConstraintsHelper.GetAbsMatFileName(matFileName);
                constraintManagerInterface.addMATFileAndConstraintsToModel(sharedConstraintList,product,matFileName,matFilePath);
                isFileLoadedInModel=true;
            catch exp
                isFileLoadedInModel=false;
            end
        end

        function isMATFileLoaded=isMATFileLoadedInModel(dataModelObj,matFileName,matFilePath)
            isMATFileLoaded=false;

            allMATFiles=dataModelObj.MATFiles;
            for m=1:allMATFiles.Size
                if strcmp(allMATFiles(m).context.matfilename,matFileName)&&strcmp(allMATFiles(m).context.matfilepath,matFilePath)
                    isMATFileLoaded=true;
                    return;
                end
            end
        end

        function constraintName=getConstraintNameFromId(dataModelObj,constraintId)
            constraintName='';
            allConstraints=dataModelObj.constraints;
            for i=1:allConstraints.Size
                if strcmp(allConstraints(i).id,constraintId)
                    constraintName=allConstraints(i).name;
                    return;
                end
            end
            if isempty(constraintName)
                allMATFiles=dataModelObj.MATFiles;
                for m=1:allMATFiles.Size
                    matFileConstraints=allMATFiles(m).matFileConstraints;
                    matFileName=allMATFiles(m).context.matfilename;
                    for i=1:matFileConstraints.Size
                        if strcmp(matFileConstraints(i).id,constraintId)
                            constraintName=[matFileName,':',matFileConstraints(i).name];
                            return;
                        end
                    end
                end
            end
        end

        function parameterConstraintName=getParameterConstraintName(dataModelObj,parameterConstraintId)
            parameterConstraintName=[];
            allConstraints=dataModelObj.constraints;
            for i=1:allConstraints.Size
                if strcmp(allConstraints(i).type,'ParameterConstraint')&&strcmp(allConstraints(i).id,parameterConstraintId)
                    parameterConstraintName=allConstraints(i).name;
                    return;
                end
            end
        end

        function pi=createPortIdentifier(portIdentifierModelObj)
            pi=Simulink.Mask.PortIdentifier;
            pi.Name=portIdentifierModelObj.name;
            pi.Type=portIdentifierModelObj.type;
            pi.IdentifierType=portIdentifierModelObj.identifierType;
            pi.Identifier=portIdentifierModelObj.identifier;
        end
    end
end

