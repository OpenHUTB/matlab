














classdef State<Simulink.SimulationData.BlockData

    properties(Access='public')
        Label=Simulink.SimulationData.StateType.CSTATE;
    end

    properties(Access='private')
        Type='CSTATE';
    end


    methods
        function this=set.Label(this,label)
            if strcmpi(label,'cstate')
                this.Label=Simulink.SimulationData.StateType.CSTATE;
                this.Type=upper(label);%#ok<MCSUP>
            elseif strcmpi(label,'dstate')
                this.Label=Simulink.SimulationData.StateType.DSTATE;
                this.Type=upper(label);%#ok<MCSUP>
            elseif strcmpi(label,'dstate_nvbus')||...
                strcmpi(label,'dstate_vbus')
                this.Label=Simulink.SimulationData.StateType.DSTATE;
                this.Type=upper(label);%#ok<MCSUP>
            elseif isequal(class(label),'Simulink.SimulationData.StateType')
                this.Label=label;
            else
                Simulink.SimulationData.utError('InvalidStateType')
            end
        end

        function disp(this)



            if length(this)~=1
                Simulink.SimulationData.utNonScalarDisp(this);
                return;
            end


            mc=metaclass(this);
            if feature('hotlinks')
                fprintf('  <a href="matlab: help %s">%s</a>\n',mc.Name,mc.Name);
            else
                fprintf('  %s\n',mc.Name);
            end


            fprintf('  Package: %s\n\n',mc.ContainingPackage.Name);


            fprintf('  Properties:\n');
            ps.Name=this.Name;
            ps.BlockPath=this.BlockPath;
            ps.Label=this.Label;
            ps.Values=this.Values;


            out=evalc('builtin(''disp'', ps);');
            oldStr='[1x1 Simulink.SimulationData.StateType]';
            if isequal(ps.Label,Simulink.SimulationData.StateType.CSTATE)
                out=strrep(out,oldStr,'CSTATE');
            elseif isequal(ps.Label,Simulink.SimulationData.StateType.DSTATE)
                out=strrep(out,oldStr,'DSTATE');
            end

            disp(out);


            if feature('hotlinks')
                fprintf('\n  <a href="matlab: methods(''%s'')">Methods</a>, ',mc.Name);
                fprintf('<a href="matlab: superclasses(''%s'')">Superclasses</a>\n',mc.Name);
            end
        end
    end


    methods(Hidden=true)
        function type=getType(this)
            type=this.Type;
        end


        function out=toStructForSimState(this,varargin)



            modifyVBusBlockPath=true;
            raccelCodePath=false;
            if nargin>1
                if nargin>2
                    id='MATLAB:tooManyInputs';
                    ME=MException(id,message(id,name,'Simulink.SimulationData.State').getString);
                    throw(ME);
                end
                if islogical(varargin{1})
                    raccelCodePath=true;
                    modifyVBusBlockPath=~varargin{1};
                end
            end
            if this.BlockPath.getLength>1
                blockPath='';
                for pIdx=1:this.BlockPath.getLength
                    blockPath=[blockPath...
                    ,slprivate('encpath',...
                    this.BlockPath.getBlock(pIdx),'','','modelref')];%#ok<AGROW>
                    if pIdx<this.BlockPath.getLength
                        blockPath=[blockPath,'|'];%#ok<AGROW>
                    end
                end
            else
                blockPath=this.BlockPath.getBlock(1);
            end

            if isstruct(this.Values)


                if nargin>1&&~raccelCodePath
                    vbStateMap=varargin{1};
                    isVBstate=false;
                    try
                        expMap=[];
                        if this.BlockPath.getLength==1

                            blkHandle=get_param(blockPath,'handle');
                            for idx=1:length(vbStateMap)



                                if vbStateMap(idx).origBlkHandle==blkHandle
                                    expMap=vbStateMap(idx).expansionMap;
                                    isVBstate=true;
                                    break;
                                end
                            end
                        else

                            thisBlkPath=this.BlockPath.getBlock(this.BlockPath.getLength);


                            for idx=1:length(vbStateMap)


                                mapBlkName=getfullname(vbStateMap(idx).origBlkHandle);
                                if strcmp(mapBlkName,thisBlkPath)
                                    expMap=vbStateMap(idx).expansionMap;
                                    isVBstate=true;
                                    break;
                                end
                            end
                        end

                        if isVBstate
                            expSize=length(expMap);
                            blockPathArray=cell(1,expSize);
                            dataCellArray=cell(1,expSize);
                            preFixBlockPath='';
                            if this.BlockPath.getLength>1
                                for pIdx=1:this.BlockPath.getLength-1
                                    preFixBlockPath=...
                                    [preFixBlockPath...
                                    ,slprivate('encpath',...
                                    this.BlockPath.getBlock(pIdx),'','','modelref')];%#ok<AGROW>
                                    if pIdx<this.BlockPath.getLength
                                        preFixBlockPath=[preFixBlockPath,'|'];%#ok<AGROW>
                                    end
                                end
                            end
                            for jdx=1:expSize

                                blockPathArray{jdx}=[preFixBlockPath,getfullname(expMap(jdx).expandedBlkHandle)];

                                expMapElement=eval(['this.Values.',expMap(jdx).string]);
                                if(isa(expMapElement,'matlab.io.datastore.TabularDatastore'))
                                    reset(expMapElement);
                                    if hasdata(expMapElement)
                                        expMapElement.ReadSize=1;
                                        tmpData=read(expMapElement);
                                        dataCellArray{jdx}=locTo1DArray(tmpData.Data);
                                    end
                                else
                                    dataCellArray{jdx}=locTo1DArray(eval(['this.Values.',expMap(jdx).string,'.Data']));
                                end
                            end
                        else



                            dataCellArray={locGetDataFromNVBusStruct(this.Values)};
                            blockPathArray={blockPath};
                        end
                    catch ex
                        id='SimulationData:Objects:CannotLoadStateForBlock';
                        newEx=MSLException([],message(id,blockPath));
                        newEx=newEx.addCause(ex);
                        throwAsCaller(newEx);
                    end
                else

                    if strcmpi(this.Type,'DSTATE_VBUS')
                        dataCellArray=locGetDataFromVBusStruct(this.Values);
                        startIdx=regexp(blockPath,'[^/]/[^/]');
                        blockName=blockPath((startIdx(end)+2):end);

                        blockPathArray=cell(numel(dataCellArray),1);
                        for dIdx=1:numel(dataCellArray)
                            if modifyVBusBlockPath
                                blockPathArray{dIdx}=strcat(blockPath,...
                                '/',blockName,'_',...
                                num2str(dIdx));
                            else
                                blockPathArray{dIdx}=blockPath;
                            end
                        end
                    elseif strcmpi(this.Type,'DSTATE_NVBUS')
                        dataCellArray={locGetDataFromNVBusStruct(this.Values)};
                        blockPathArray={blockPath};
                    else
                        id='SimulationData:Objects:CannotLoadStateForBlock';
                        newEx=MSLException([],message(id,blockPath));
                        throwAsCaller(newEx);
                    end
                end
            else
                if(~strcmpi(this.Type,'DSTATE')&&~strcmpi(this.Type,'CSTATE'))
                    id='SimulationData:Objects:InvalidStateType';
                    newEx=MException(id,message(id));
                    throwAsCaller(newEx);
                end

                f=@(x){locTo1DArray(x)};
                dataCellArray=setDataCellArray(this.Values,f);
                blockPathArray={blockPath};
            end

            out=repmat(struct(...
            'values',0,...
            'dimensions',1,...
            'label',char(this.Label),...
            'blockName','',...
            'stateName',this.Name,...
            'inReferencedModel',(this.BlockPath.getLength>1)...
            ),1,numel(dataCellArray));

            for dIdx=1:numel(dataCellArray)
                out(dIdx).values=dataCellArray{dIdx};
                out(dIdx).dimensions=numel(dataCellArray{dIdx});
                out(dIdx).blockName=blockPathArray{dIdx};
            end
        end
    end
end


function out=locGetDataFromVBusStruct(val)
    out={};
    fieldNames=fieldnames(val);
    for fIdx=1:numel(fieldNames)
        field=getfield(val,fieldNames{fIdx});%#ok<GFLD>
        if isstruct(field)
            out=[out,locGetDataFromVBusStruct(field)];%#ok<AGROW>
        else
            out=[out,{locTo1DArray(field.Data)}];%#ok<AGROW>
        end
    end
end


function out=locGetDataFromNVBusStruct(val)
    out=locTo1DArray(val);
    for dIdx=1:numel(out)
        fieldNames=fieldnames(out(dIdx));
        for fIdx=1:numel(fieldNames)
            field=getfield(out(dIdx),fieldNames{fIdx});%#ok<GFLD>
            if isstruct(field)
                out(dIdx)=setfield(out(dIdx),fieldNames{fIdx},...
                locGetDataFromNVBusStruct(field));%#ok<SFLD>
            else
                f=@(x)setfield(out(dIdx),...
                fieldNames{fIdx},locTo1DArray(x));
                out(dIdx)=setDataCellArray(field,f);
            end
        end
    end
end


function out=setDataCellArray(var,setCellDataFcn)



    if(isa(var,'matlab.io.datastore.TabularDatastore'))
        reset(var);
        if hasdata(var)
            var.ReadSize=1;
            tmpData=read(var);
            out=setCellDataFcn(tmpData.Data);
        end
    else
        out=setCellDataFcn(var.Data);
    end
end


function out=locTo1DArray(val)
    out=reshape(val,1,numel(val));
end



