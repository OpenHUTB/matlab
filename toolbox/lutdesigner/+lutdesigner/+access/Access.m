classdef Access

    properties(Abstract,Constant)
        Type(1,:)char{mustBeMember(Type,{...
'model'...
        ,'subsystem'...
        ,'subsystemReference'...
        ,'sfchart'...
        ,'modelBlock'...
        ,'lookupTableBlock'...
        ,'lookupTableControl'...
        })}
    end

    properties(Abstract,SetAccess=immutable)
        Path(1,:)char
    end

    methods(Static)
        function access=fromSimulinkComponent(slComponent)
            slType=get_param(slComponent,'Type');
            slPath=regexprep(getfullname(slComponent),'\n',' ');

            if strcmp(slType,'block_diagram')
                access=lutdesigner.access.Model(slPath);
                return;
            end

            if lutdesigner.lutfinder.LookupTableFinder.isLookupTableBlock(slPath)
                access=lutdesigner.access.LookupTableBlock(slPath);
                return;
            end

            blockType=get_param(slPath,'BlockType');

            if strcmp(blockType,'ModelReference')
                access=lutdesigner.access.ModelBlock(slPath);
                return;
            end

            if strcmp(blockType,'SubSystem')
                if strcmp(get_param(slPath,'SFBlockType'),'Chart')
                    access=lutdesigner.access.SfChart(slPath);
                    return;
                end

                if~isempty(get_param(slPath,'ReferencedSubsystem'))
                    access=lutdesigner.access.SubSystemReference(slPath);
                    return;
                end

                access=lutdesigner.access.SubSystem(slPath);
                return;
            end

            if lutdesigner.lutfinder.LookupTableFinder.hasLookupTableControl(slPath,'Visible','on')
                access=lutdesigner.access.SubSystem(slPath);
                return;
            end

            error(message('lutdesigner:messages:UnsupportedAccess'));
        end

        function access=fromDesc(desc)
            switch desc.type
            case 'model'
                access=lutdesigner.access.Model(desc.path);
            case 'subsystem'
                access=lutdesigner.access.SubSystem(desc.path);
            case 'subsystemReference'
                access=lutdesigner.access.SubSystemReference(desc.path);
            case 'sfchart'
                access=lutdesigner.access.SfChart(desc.path);
            case 'modelBlock'
                access=lutdesigner.access.ModelBlock(desc.path);
            case 'lookupTableBlock'
                access=lutdesigner.access.LookupTableBlock(desc.path);
            case 'lookupTableControl'
                [block,ctrl]=fileparts(desc.path);
                access=lutdesigner.access.LookupTableControl(block,ctrl);
            otherwise
                error(message('lutdesigner:messages:UnsupportedAccess'));
            end
        end

        function accessDesc=createDesc(type,path,parentType)
            accessDesc=struct('type',type,'path',path,'parentType','');
            if nargin>2
                accessDesc.parentType=parentType;
            end
        end

        function accessDesc=createDescArray(sz)
            accessDesc=repmat(lutdesigner.access.Access.createDesc('',''),sz);
        end

        function indices=findPathDelimiters(path)
            indices=strfind(path,regexpPattern('[^/]/[^/]'))+1;
        end

        function tf=containsByPath(path1,path2)
            tf=strcmp(path1,path2)||(startsWith(path2,[path1,'/'])&&~startsWith(path2,[path1,'//']));
        end

        function parts=extractPathParts(path)
            delimiterIndices=lutdesigner.access.Access.findPathDelimiters(path);
            if isempty(delimiterIndices)
                parts={path};
            else
                parts=arrayfun(@(startIndex,endIndex)path(startIndex:endIndex),...
                [1,delimiterIndices+1],[delimiterIndices-1,strlength(path)],'UniformOutput',false);
            end
        end
    end

    methods
        function accessDesc=toDesc(this)
            accessDesc=this.createDesc(this.Type,this.Path);
        end

        function id=getId(this)
            id=sprintf('%s:%s',this.Type,this.Path);
        end
    end

    methods(Abstract)
        tf=isAvailable(this);

        tf=contains(this,that);

        show(this);

        accessDescs=getSubAccessDescs(this);
    end
end
