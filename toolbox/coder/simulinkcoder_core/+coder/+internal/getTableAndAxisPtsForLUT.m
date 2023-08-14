function retVal=getTableAndAxisPtsForLUT(blockPath,varargin)

















































    blockType=get_param(blockPath,'BlockType');


    retVal={int32(-1),int32(-1)};

    if strcmp(blockType,'Lookup_n-D')
        dims=get_param(blockPath,'NumberOfTableDimensions');
        dims=str2double(dims);
        dims=int32(dims);
    elseif strcmp(blockType,'Interpolation_n-D')
        if nargin==2

            xPreLUTBlockPath=varargin{1};
            xPreLUTBlockType=get_param(xPreLUTBlockPath,'BlockType');
            if strcmp(xPreLUTBlockType,'PreLookup')
                dims=int32(1);
            end
        elseif nargin==3

            xPreLUTBlockPath=varargin{1};
            xPreLUTBlockType=get_param(xPreLUTBlockPath,'BlockType');
            yPreLUTBlockPath=varargin{2};
            yPreLUTBlockType=get_param(yPreLUTBlockPath,'BlockType');
            if strcmp(xPreLUTBlockType,'PreLookup')&&...
                strcmp(yPreLUTBlockType,'PreLookup')
                dims=int32(2);
            end
        else

            return;
        end
    else

        return;
    end



    if dims<1||dims>2
        return;
    end

    if strcmp(blockType,'Lookup_n-D')&&...
        strcmp(get_param(blockPath,'DataSpecification'),'Lookup table object')

        lutObjName=get_param(blockPath,'LookupTableObject');
        if~isempty(lutObjName)
            model=bdroot(blockPath);
            [~,lutObj]=coder.internal.evalObject(model,lutObjName);
            isTunableSize=lutObj.SupportTunableSize;
            if(dims==1)
                if isequal(get_param(model,'LUTObjectStructOrderExplicitValues'),'Size,Table,Breakpoints')

                    if isTunableSize
                        tbPos=1;
                        bpPos=2;
                    else
                        tbPos=0;
                        bpPos=1;
                    end
                else

                    if isTunableSize
                        tbPos=2;
                        bpPos=1;
                    else
                        tbPos=1;
                        bpPos=0;
                    end
                end
                retVal={int32(dims),int32(tbPos),int32(bpPos)};
            elseif(dims==2)
                if isequal(get_param(model,'LUTObjectStructOrderExplicitValues'),'Size,Table,Breakpoints')

                    if isTunableSize
                        tbPos=2;
                        bp1Pos=3;
                        bp2Pos=4;
                    else
                        tbPos=0;
                        bp1Pos=1;
                        bp2Pos=2;
                    end
                else

                    if isTunableSize
                        tbPos=4;
                        bp1Pos=2;
                        bp2Pos=3;
                    else
                        tbPos=2;
                        bp1Pos=0;
                        bp2Pos=1;
                    end
                end
                retVal={int32(dims),int32(tbPos),int32(bp1Pos),int32(bp2Pos)};
            end
        end
        return;
    end

    tableVal=get_param(blockPath,'Table');
    tmp=regexp(tableVal,'\.','split');
    if length(tmp)~=2
        return;
    end



    structName=tmp{1};
    tableFieldName=tmp{2};
    [~,prmObj]=coder.internal.evalObject(bdroot(blockPath),structName);
    if isempty(prmObj)||~isa(prmObj,'Simulink.Parameter')
        return;
    end


    dataType=prmObj.DataType;
    busObjectName=regexprep(dataType,'Bus:\s*','');
    [~,busObject]=coder.internal.evalObject(bdroot(blockPath),busObjectName);
    if isempty(busObject)||~isa(busObject,'Simulink.Bus')
        return;
    end

    busElemNames=arrayfun(@(x)x.Name,busObject.Elements,...
    'UniformOutput',false);


    tablePos=find(strcmp(busElemNames,tableFieldName))-1;
    if isempty(tablePos)||numel(busElemNames)~=dims+1
        return;
    end

    if dims==1


        if strcmp(blockType,'Lookup_n-D')
            bp1=get_param(blockPath,'BreakpointsForDimension1');
        elseif strcmp(blockType,'Interpolation_n-D')
            bp1=get_param(xPreLUTBlockPath,'BreakpointsData');
        end
        tmp=regexp(bp1,'\.','split');
        if length(tmp)~=2||~strcmp(tmp{1},structName)
            return;
        end



        bp1FieldName=tmp{2};
        bp1Pos=find(strcmp(busElemNames,bp1FieldName))-1;
        if isempty(bp1Pos)
            return;
        end

        tablePos=int32(tablePos);
        bp1Pos=int32(bp1Pos);
        retVal={dims,tablePos,bp1Pos};

    elseif dims==2


        if strcmp(blockType,'Lookup_n-D')
            bp1=get_param(blockPath,'BreakpointsForDimension1');
            bp2=get_param(blockPath,'BreakpointsForDimension2');
        elseif strcmp(blockType,'Interpolation_n-D')
            bp1=get_param(xPreLUTBlockPath,'BreakpointsData');
            bp2=get_param(yPreLUTBlockPath,'BreakpointsData');
        end
        tmp1=regexp(bp1,'\.','split');
        tmp2=regexp(bp2,'\.','split');
        if length(tmp1)~=2||length(tmp2)~=2||...
            ~strcmp(tmp1{1},structName)||~strcmp(tmp2{1},structName)
            return;
        end



        bp1FieldName=tmp1{2};
        bp2FieldName=tmp2{2};
        bp1Pos=find(strcmp(busElemNames,bp1FieldName))-1;
        bp2Pos=find(strcmp(busElemNames,bp2FieldName))-1;
        if isempty(bp1Pos)||isempty(bp2Pos)
            return;
        end

        tablePos=int32(tablePos);
        bp1Pos=int32(bp1Pos);
        bp2Pos=int32(bp2Pos);
        retVal={dims,tablePos,bp1Pos,bp2Pos};

    end
end


