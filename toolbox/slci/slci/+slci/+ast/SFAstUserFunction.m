





classdef SFAstUserFunction<slci.ast.SFAstFunction
    methods(Access=protected)


        function out=IsInvalidMixedType(aObj)
            out=false;
            if(~aObj.IsUnsupportedFunction()&&...
                ~aObj.isSFSLFunction()&&...
                ~aObj.IsGraphicalFunction()&&...
                ~aObj.IsTruthTable()&&...
                ~strcmpi(aObj.fName,'ldexp')&&...
                ~isempty(aObj.getChildren()))
                out=aObj.IsMixedType;
            end
        end


        function out=IsInvalidOperandType(aObj)
            if aObj.isSFSLFunction()||...
                aObj.IsGraphicalFunction()||...
                aObj.IsTruthTable()||...
                aObj.isSimulinkFunctionCall()


                out=false;
                return;
            end
            children=aObj.getChildren();
            dt1='';
            dt2='';
            if numel(children)>=1
                dt1=children{1}.getDataType();
            end
            if numel(children)>=2
                dt2=children{2}.getDataType();
            end
            switch aObj.fName
            case{'acos',...
                'asin',...
                'atan',...
                'ceil',...
                'cos',...
                'cosh',...
                'exp',...
                'fabs',...
                'floor',...
                'fmod',...
                'ldexp',...
                'log',...
                'log10',...
                'pow',...
                'sin',...
                'sinh',...
                'sqrt',...
                'tan',...
                'tanh'}
                out=~slci.stateflow.SFUtil.IsReal(dt1);
            case 'atan2'
                out=~slci.stateflow.SFUtil.IsReal(dt1)||...
                ~slci.stateflow.SFUtil.IsReal(dt2);
            case{'abs',...
                'labs',...
                'max',...
                'min'}
                out=strcmp(dt1,'boolean');
            otherwise

                out=false;
            end
        end

        function out=getFirstOutputName(~,UDDObj)
            firstOutputName=strtrim(textscan(...
            UDDObj.LabelString,'%s','Delimiter','='));
            firstOutputName=firstOutputName{1}{1};


            if(firstOutputName(1)=='[')
                firstOutputName=strtrim(textscan(...
                firstOutputName(2:end),'%s','Delimiter',','));
                firstOutputName=firstOutputName{1}{1};
            end

            out=firstOutputName;
        end

    end

    methods


        function aObj=SFAstUserFunction(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAstFunction(aAstObj,aParent);
            aObj.setName(aAstObj);
            aObj.setSfId(aAstObj,aParent);


            funcUDDObj=idToHandle(sfroot,aObj.fSfId);
            if(isa(funcUDDObj,'Stateflow.Function')...
                ||isa(funcUDDObj,'Stateflow.TruthTable'))...
                &&isa(aObj.getRootAstOwner(),'slci.stateflow.Transition')




                isParentStateflowFunction=...
                isa(aObj.getRootAstOwner.getParent(),...
                'slci.stateflow.StateflowFunction');
                if isParentStateflowFunction
                    aObj.ParentChart.setAdjacentFunction(...
                    aObj.getRootAstOwner.getParent.getSfId(),...
                    aObj.fSfId);
                end
            end
        end


        function setName(aObj,aAstObj)
            snippetCell=textscan(aAstObj.sourceSnippet,'%s','Delimiter','(');
            aObj.fName=strtrim(snippetCell{1}{1});
        end


        function setSfId(aObj,aAstObj,~)
            aObj.fSfId=aAstObj.id;
        end


        function out=isSFSLFunction(aObj)
            if aObj.fSfId~=0
                fnPath=aObj.getFunctionPath;
                out=aObj.ParentChart.isSFSLFunction(fnPath);
            else
                out=false;
            end
        end

        function ComputeDataType(aObj)
            assert(~aObj.fComputedDataType);
            if aObj.isSimulinkFunctionCall()

                retTypes=aObj.fSLFcnInfo.getReturnTypes;
                assert(numel(retTypes)==1,["SFAstUserFunction can only be void"...
                ," or has one return argument"]);
                aObj.fDataType=retTypes{1};
            elseif aObj.isSFSLFunction()

                ss=aObj.getSLFunctionSSHandle();
                ph=get_param(ss,'PortHandles');
                if~isempty(ph.Outport)
                    ssOutportDataType=get_param(ph.Outport(1),...
                    'CompiledPortDataType');
                    aObj.fDataType=ssOutportDataType;
                else
                    aObj.fDataType='double';
                end
            elseif aObj.IsGraphicalFunction()
                if aObj.hasOutput()

                    gfnObj=aObj.ParentChart.getGraphicalFunctionObject(aObj.fSfId);
                    gfnUDDObj=gfnObj.getUDDObject();
                    firstOutputName=aObj.getFirstOutputName(gfnUDDObj);
                    children=gfnUDDObj.getChildren();
                    firstOutputData=children(arrayfun(@(x)(isa(x,'Stateflow.Data')&&...
                    strcmpi(x.Scope,'Output')&&...
                    strcmpi(x.Name,firstOutputName)),gfnUDDObj.getChildren()));
                    aObj.fDataType=firstOutputData.CompiledType;
                else
                    aObj.fDataType='double';
                end
            elseif aObj.IsTruthTable()
                if aObj.hasOutput()

                    tblObj=aObj.ParentChart.getTruthTableObject(aObj.fSfId);
                    tblUDDObj=tblObj.getUDDObject();
                    firstOutputName=aObj.getFirstOutputName(tblUDDObj);
                    children=tblUDDObj.find('-isa','Stateflow.Data');
                    firstOutputData=children(arrayfun(@(x)(strcmpi(x.Scope,'Output')&&...
                    strcmpi(x.Name,firstOutputName)),children));
                    aObj.fDataType=firstOutputData.CompiledType;
                else
                    aObj.fDataType='double';
                end
            else
                switch aObj.fName

                case{'acos',...
                    'asin',...
                    'atan',...
                    'atan2',...
                    'ceil',...
                    'cos',...
                    'cosh',...
                    'exp',...
                    'floor',...
                    'fmod',...
                    'log',...
                    'log10',...
                    'pow',...
                    'rand',...
                    'sin',...
                    'sinh',...
                    'sqrt',...
                    'tan',...
                    'tanh',...
                    'ldexp'}
                    children=aObj.getChildren();
                    if isempty(children)
                        aObj.fDataType='double';
                    else
                        aObj.fDataType=children{1}.getDataType();
                    end
                    if~strcmp(aObj.fDataType,'single')
                        aObj.fDataType='double';
                    end
                case{'abs',...
                    'fabs',...
                    'labs',...
                    'min',...
                    'max'}
                    children=aObj.getChildren();
                    if isempty(children)
                        aObj.fDataType='double';
                    else
                        aObj.fDataType=children{1}.getDataType();
                    end
                otherwise
                    aObj.fDataType='double';
                end
            end
        end


        function ComputeDataDim(aObj)
            assert(~aObj.fComputedDataDim);
            children=aObj.getChildren();
            if aObj.isSimulinkFunctionCall()
                aObj.fDataDim=aObj.fSLFcnInfo.getReturnWidthAt(1);
            elseif aObj.isSFSLFunction()
                if isempty(children)
                    aObj.fDataDim=1;
                else

                    ss=aObj.getSLFunctionSSHandle();
                    ph=get_param(ss,'PortHandles');
                    if~isempty(ph.Outport)
                        ssOutportDataDim=get_param(ph.Outport(1),...
                        'CompiledPortWidth');
                        aObj.fDataDim=ssOutportDataDim;
                    else
                        aObj.fDataDim=1;
                    end
                end

            elseif aObj.IsGraphicalFunction()
                if aObj.hasOutput()

                    gfnObj=aObj.ParentChart.getGraphicalFunctionObject(aObj.fSfId);
                    gfnUDDObj=gfnObj.getUDDObject();
                    firstOutputName=aObj.getFirstOutputName(gfnUDDObj);
                    children=gfnUDDObj.getChildren();
                    firstOutputData=children(arrayfun(@(x)(isa(x,'Stateflow.Data')&&...
                    strcmpi(x.Scope,'Output')&&...
                    strcmpi(x.Name,firstOutputName)),gfnUDDObj.getChildren()));
                    aObj.fDataDim=str2double(firstOutputData.CompiledSize);
                else
                    aObj.fDataDim=1;
                end

            elseif aObj.IsTruthTable()
                if aObj.hasOutput()

                    tblObj=aObj.ParentChart.getTruthTableObject(aObj.fSfId);
                    tblUDDObj=tblObj.getUDDObject();
                    firstOutputName=aObj.getFirstOutputName(tblUDDObj);
                    children=tblUDDObj.find('-isa','Stateflow.Data');
                    firstOutputData=children(arrayfun(@(x)(strcmpi(x.Scope,'Output')&&...
                    strcmpi(x.Name,firstOutputName)),children));
                    aObj.fDataDim=str2double(firstOutputData.CompiledSize);
                else
                    aObj.fDataDim=1;
                end

            else

                switch aObj.fName

                case{'acos',...
                    'asin',...
                    'atan',...
                    'atan2',...
                    'ceil',...
                    'cos',...
                    'cosh',...
                    'exp',...
                    'floor',...
                    'fmod',...
                    'log',...
                    'log10',...
                    'pow',...
                    'rand',...
                    'sin',...
                    'sinh',...
                    'sqrt',...
                    'tan',...
                    'tanh'}
                    if isempty(children)
                        aObj.fDataDim=1;
                    else
                        aObj.fDataDim=children{1}.getDataDim();
                    end
                case 'ldexp'
                    aObj.fDataDim=children{1}.getDataDim();
                case{'abs',...
                    'fabs',...
                    'labs'}
                    if isempty(children)
                        aObj.fDataDim=1;
                    else
                        aObj.fDataDim=children{1}.getDataDim();
                    end
                case{'min',...
                    'max'}
                    if isempty(children)
                        aObj.fDataDim=1;
                    else
                        aObj.fDataDim=aObj.ResolveDataDim();
                    end
                otherwise
                    aObj.fDataDim=1;
                end
            end
        end


        function out=getNumInputs(aObj)
            out=numel(aObj.getChildren());
        end


        function out=hasOutput(aObj)




            out=false;
            if aObj.IsGraphicalFunction()
                gfnObj=aObj.ParentChart.getGraphicalFunctionObject(aObj.fSfId);
                if gfnObj.getNumOutputs()
                    out=true;
                end
            elseif aObj.IsTruthTable()
                tableObj=aObj.ParentChart.getTruthTableObject(aObj.fSfId);
                if tableObj.getNumOutputs()
                    out=true;
                end
            else

            end
        end
    end

    methods(Access=protected)


        function out=IsEnumCast(aObj)
            out=Simulink.data.isSupportedEnumClass(aObj.fName);
        end


        function out=IsUnsupportedFunction(aObj)
            out=true;%#ok
            switch aObj.fName

            case aObj.MATH_FNS
                out=false;
            otherwise

                if aObj.isSFSLFunction()
                    out=false;
                elseif aObj.IsGraphicalFunction()
                    out=false;
                elseif aObj.IsTruthTable()
                    out=false;
                elseif aObj.isSimulinkFunctionCall()
                    out=false;
                else
                    out=~Simulink.data.isSupportedEnumClass(aObj.fName);
                end
            end
        end

    end

end


