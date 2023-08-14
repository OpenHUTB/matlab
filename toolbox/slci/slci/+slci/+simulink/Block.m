



classdef Block<slci.common.BdObject

    properties(Access=private)
        fModel=[];
        fSupportsBuses=false;
        fSupportsEnums=false;
        fSupportsString=false;
        fHandle=-1;



        fSupportsEnumsForIndexPortDataType=false;
    end

    methods

        function obj=Block(aBlockHdl,aModel)
            obj.fModel=aModel;
            obj.fClassName=DAStudio.message('Slci:compatibility:ClassNameBlock');
            obj.fClassNames=DAStudio.message('Slci:compatibility:ClassNameBlocks');
            obj.setHandle(aBlockHdl);
            obj.setSID(Simulink.ID.getSID(aBlockHdl));
            obj.setUDDObject(get_param(aBlockHdl,'Object'));
            obj.setName(slci.compatibility.getFullBlockName(aBlockHdl));





            if~obj.getVirtual()&&...
                ~strcmpi(class(obj),'slci.simulink.UnsupportedBlock')&&...
                (~aModel.getAutodoc()||...
                strcmpi(class(obj),'slci.simulink.Block'))
                obj.addCommonConstraints;
            end

            obj.addSLCILevel1Checks;

        end

        function addCommonConstraints(aObj)
            aObj.addConstraint(...
            slci.compatibility.BlockNameConstraint);
            aObj.addConstraint(...
            slci.compatibility.BlockPortsNonComplexConstraint);
            aObj.addConstraint(...
            slci.compatibility.BlockPortsMultiDimConstraint);
            aObj.addConstraint(...
            slci.compatibility.BlockPortsNonFramedConstraint);
            aObj.addConstraint(...
            slci.compatibility.BlockOutPortStorageClassConstraint);
            aObj.addConstraint(...
            slci.compatibility.BlockOutPortConstantTestpointedConstraint);
            aObj.addConstraint(...
            slci.compatibility.BlockOutPortConstantNonAutoScConstraint);
            aObj.addConstraint(...
            slci.compatibility.SupportedPortDataTypesConstraint(...
            {'double','single','int8','uint8','int16',...
            'uint16','int32','uint32','boolean','fcn_call'}));
            aObj.addConstraint(...
            slci.compatibility.PrmSampletimeBlockDestinationConstraint);
        end

        function addSLCILevel1Checks(aObj)

            if(slcifeature('SlciLevel1Checks')==1)

                aObj.addConstraint(...
                slci.compatibility.BlockPortsCompiledDatatypeConstraint);
                aObj.addConstraint(...
                slci.compatibility.BlockPortsCompiledDimensionConstraint);

                aObj.addConstraint(...
                slci.compatibility.SignalDatatypeConstraint);
                aObj.addConstraint(...
                slci.compatibility.SignalDimensionConstraint);
            end
        end

        function out=getHandle(aObj)
            out=aObj.fHandle;
        end

        function setHandle(aObj,aHdl)
            aObj.fHandle=aHdl;
        end

        function out=getSupportsBuses(aObj)
            out=aObj.fSupportsBuses;
        end

        function setSupportsBuses(aObj,aSupportsBuses)
            aObj.fSupportsBuses=aSupportsBuses;
        end

        function out=getSupportsEnums(aObj)
            out=aObj.fSupportsEnums;
        end

        function setSupportsEnums(aObj,aSupportsEnums)
            aObj.fSupportsEnums=aSupportsEnums;
        end


        function out=getSupportsString(aObj)
            out=aObj.fSupportsString;
        end


        function setSupportsString(aObj,aSupportsString)
            aObj.fSupportsString=aSupportsString;
        end


        function out=getSupportsEnumsForIndexPortDataType(aObj)
            out=aObj.fSupportsEnumsForIndexPortDataType;
        end


        function setSupportsEnumsForIndexPortDataType(aObj,aSupportsEnumsForIndexPortDataType)
            aObj.fSupportsEnumsForIndexPortDataType=aSupportsEnumsForIndexPortDataType;
        end

        function out=ParentModel(aObj)
            out=aObj.fModel;
        end

        function out=ParentBlock(aObj)
            out=aObj;
        end

        function out=getVirtual(aObj)
            isBlkVirtual=strcmpi(aObj.getParam('Virtual'),'on');
            isRootOutport=strcmpi(aObj.getParam('BlockType'),'Outport')&&...
            strcmpi(aObj.getParam('Parent'),aObj.ParentModel().getName());
            isRootInport=strcmpi(aObj.getParam('BlockType'),'Inport')&&...
            strcmpi(aObj.getParam('Parent'),aObj.ParentModel().getName());

            if isRootOutport
                out=false;
            else


                out=isBlkVirtual||isRootInport;
            end
        end

        function listCompatibility(aObj)
            constraints=aObj.getConstraints();
            if isempty(constraints)
                if aObj.ParentModel().getAutodoc()
                    disp('   There are no block-specific constraints')
                end
            else
                for idx=1:numel(constraints)
                    constraints{idx}.list()
                end
            end
        end

        function out=checkCompatibility(aObj)
            out=[];


            sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
            obj=aObj.getParam('Object');
            isPostCompileVirtual=obj.isPostCompileVirtual;

            constraints=aObj.getConstraints();
            if isPostCompileVirtual

                idxs=cellfun(@(x)x.getCompileNeeded()==1,constraints);
                constraints=constraints(~idxs);
            end

            for idx=1:numel(constraints)
                [failures,preReqConstraintFailure]=constraints{idx}.checkCompatibility();



                if~preReqConstraintFailure
                    out=[out,failures];%#ok
                end
            end
        end



        function constAst=createAstForBlockParam(aObj,param)
            constAst={};
            ast=slci.matlab.astTranslator.translateMATLABExpr(param,aObj);
            constAst{1}=ast;
        end

    end
end


