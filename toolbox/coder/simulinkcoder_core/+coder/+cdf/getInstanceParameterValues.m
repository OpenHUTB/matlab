function retVal=getInstanceParameterValues(modelName,blkName,varargin)




    retVal{1}=false;
    retVal{2}=[];
    if ischar(blkName)&&matches(get_param([modelName,'/',blkName],'BlockType'),'ModelReference')...
        &&matches(get_param([modelName,'/',blkName],'ProtectedModel'),'off')

        instanceParams=get_param([modelName,'/',blkName],'InstanceParameters');
        instanceParamsList=cell(0,0);


        for i1=1:numel(instanceParams)
            path=instanceParams(i1).Path.convertToCell();
            instNamePath=join(arrayfun(@(x)extractAfter(x{1},'/'),path,'UniformOutput',false),'/');

            if isempty(instNamePath)
                instNamePath=[blkName,'/',instanceParams(i1).Name];
            else
                instNamePath=[blkName,'/',instNamePath{1},'/',instanceParams(i1).Name];
            end
            if numel(varargin)>0&&~isempty(varargin{1})
                instNamePath=[varargin{1},'/',instNamePath];
            end


            [instPExist,instPValue]=coder.internal.evalObject(modelName,evaluateExpression(instanceParams(i1).Value));
            if instPExist
                if isa(instPValue,'Simulink.Breakpoint')
                    unit=instPValue.Breakpoints.Unit;
                    if isempty(unit)
                        unit='';
                    end
                    instanceParamsList{end+1}={instNamePath,{unit,evaluateExpression(instPValue.Breakpoints.Value)}};
                    breakpoints=instPValue.Breakpoints;
                    breakpointsList=cell(1,numel(breakpoints));
                    for bpIdx=1:numel(breakpoints)
                        unit=breakpoints(bpIdx).Unit;
                        if isempty(unit)
                            unit='';
                        end
                        breakpointsList{bpIdx}={unit,evaluateExpression(breakpoints(bpIdx).Value)};
                    end
                    unit=instPValue.Table.Unit;
                    if isempty(unit)
                        unit='';
                    end
                    instanceParamsList{end+1}={instNamePath,{unit,evaluateExpression(instPValue.Table.Value)},breakpointsList};
                elseif isa(instPValue,'Simulink.Parameter')
                    unit=instPValue.Unit;
                    if isempty(unit)
                        unit='';
                    end
                    instanceParamsList{end+1}={instNamePath,{unit,evaluateExpression(instPValue.Value)}};
                else
                    instanceParamsList{end+1}={instNamePath,{'',instPValue}};
                end
            else
                if~isempty(instanceParams(i1).Value)
                    instanceParamsList{end+1}={instNamePath,{'',evaluateExpression(eval(instanceParams(i1).Value))}};
                else
                    botModelName=get_param([modelName,'/',blkName],'ModelFile');
                    isNotProtected=matches(get_param([modelName,'/',blkName],'ProtectedModel'),'off');
                    if~isempty(botModelName)&&isNotProtected
                        botModelName=extractBefore(botModelName,'.');
                        [~,botParam]=fileparts(instNamePath);
                        [varExists,object]=coder.internal.evalObject(botModelName,botParam);
                        if varExists
                            if isa(object,'Simulink.Breakpoint')
                                instanceParamsList{end+1}={instNamePath,{object.Breakpoints.Unit,evaluateExpression(object.Breakpoints.Value)}};
                            elseif isa(object,'Simulink.LookupTable')
                                breakpoints=object.Breakpoints;
                                breakpointsList=cell(1,numel(breakpoints));
                                for bid=1:numel(breakpoints)
                                    if any(matches(object.BreakpointsSpecification,'Explicit values'))
                                        bpData=object.Breakpoints(bid);
                                        if isa(bpData,'Simulink.lookuptable.Breakpoint')
                                            unit=bpData.Unit;
                                            bpvalue=bpData.Value;
                                            if isempty(unit)
                                                unit='';
                                            end
                                            breakpointsList{bid}={unit,bpvalue};
                                        end
                                    end
                                end
                                unit=object.Table.Unit;
                                instanceParamsList{end+1}={instNamePath,{unit,evaluateExpression(object.Table.Value),object.Table.Description},{object.BreakpointsSpecification,breakpointsList}};
                            elseif isa(object,'Simulink.Signal')
                                botParamUnit=object.Unit;
                                botParamValue=eval(evaluateExpression(object.InitialValue));
                                instanceParamsList{end+1}={instNamePath,{botParamUnit,botParamValue}};
                            elseif isa(object,'Simulink.Parameter')
                                instanceParamsList{end+1}={instNamePath,{object.Unit,evaluateExpression(object.Value)}};
                            else
                                instanceParamsList{end+1}={instNamePath,{'',evaluateExpression(object)}};
                            end
                        end
                    end
                end
            end
            for pathId=1:numel(path)
                [subModelName,subBlkName]=fileparts(path{pathId});
                if numel(varargin)>0&&~isempty(varargin{1})
                    subMap=coder.cdf.getInstanceParameterValues(subModelName,subBlkName,[varargin{1},'/',blkName]);
                else
                    subMap=coder.cdf.getInstanceParameterValues(subModelName,subBlkName,blkName);
                end
                if subMap{1}
                    for subMpId=1:numel(subMap{2})
                        paramFound=false;
                        for instPLID=1:numel(instanceParamsList)
                            paramFound=matches(instanceParamsList{instPLID}{1},subMap{2}{subMpId}{1});
                            if paramFound
                                break;
                            end
                        end
                        if paramFound
                            continue;
                        end
                        instanceParamsList{end+1}=subMap{2}{subMpId};
                    end
                end
            end
        end
        retVal{1}=true;
        retVal{2}=instanceParamsList;
    end
end

function value=evaluateExpression(value)
    if isa(value,'Simulink.data.Expression')
        try
            value=eval(value.ExpressionString);
        catch
            value=[];
        end
    end
end


