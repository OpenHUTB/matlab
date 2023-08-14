classdef IDLGenerator<handle





    properties(Constant)
        SPACER='   ';
    end

    properties
Model
DependencyVisitor
StartElements
EndElements
KeyAsComment
Dependencies
CompletedMap
System
UseShortNameForType
    end

    methods
        function h=IDLGenerator(model,keyAsComment)
            h.Model=model;
            h.System=dds.internal.getSystemInModel(h.Model);
            h.KeyAsComment=keyAsComment;
            h.DependencyVisitor=dds.internal.DependencyVisitor;
            h.DependencyVisitor.visitModel(h.Model);
            h.Dependencies=h.DependencyVisitor.getDepedencies(h.Model);
            h.CompletedMap=containers.Map(h.Dependencies.TypeLibraries,zeros(1,numel(h.Dependencies.TypeLibraries),'logical'));
            h.generate;
        end


        function generate(h)
            h.StartElements={};
            h.EndElements={};
            for idx=1:numel(h.Dependencies.TypeLibraries)
                [startElements,endElements]=h.processElement(h.Dependencies.TypeLibraries{idx});
                [h.StartElements,h.EndElements]=h.concatElements(h.StartElements,h.EndElements,startElements,endElements,'');
            end
        end


        function out=getStr(h)
            outC=[h.StartElements,h.EndElements];
            out=strjoin(outC,newline);
        end


        function[startElements,endElements]=concatElements(~,startElements,endElements,startInnerElements,endInnerElements,prespace)
            startElements=[startElements,cellfun(@(x)[prespace,x],startInnerElements,'UniformOutput',false)];
            endElements=[endElements,cellfun(@(x)[prespace,x],endInnerElements,'UniformOutput',false)];
        end


        function[startElements,endElements]=processElement(h,elemFullName)
            if h.CompletedMap(elemFullName)
                startElements={};
                endElements={};
                return;
            end

            elem=h.Model.findElement(h.DependencyVisitor.TypesMap(elemFullName));
            switch(class(elem))
            case 'dds.datamodel.types.Enum'
                [startElements,endElements]=h.processEnum(elem,elemFullName);
            case 'dds.datamodel.types.Const'
                [startElements,endElements]=h.processConst(elem,elemFullName);
            case 'dds.datamodel.types.Struct'
                [startElements,endElements]=h.processStruct(elem,elemFullName);
            case 'dds.datamodel.types.Module'
                [startElements,endElements]=h.processModule(elem,elemFullName);
            case 'dds.datamodel.types.Alias'
                [startElements,endElements]=h.processAlias(elem,elemFullName);
            end
            h.CompletedMap(elemFullName)=true;
        end



        function[startElements,endElements]=processEnum(h,elem,~)
            startElements{1}=['enum ',elem.Name];
            startElements{2}='{';
            keys=elem.Members.keys;
            for i=1:elem.Members.Size
                member=elem.Members{keys(i)};
                if i~=elem.Members.Size
                    endStr=',';
                else
                    endStr='';
                end
                if~isempty(member.RoundTripInfo)&&member.RoundTripInfo.Optional

                    endStr=[endStr,' //@optional'];%#ok<AGROW> 
                end
                if~isempty(member.ValueStr)
                    startElements{2+i}=[h.SPACER,member.Name,' =  ',member.ValueStr,endStr];
                else
                    startElements{2+i}=[h.SPACER,member.Name,endStr];
                end
            end
            startElements{end+1}=['}; //',elem.Name];
            endElements={};
        end


        function[startElements,endElements]=processConst(h,elem,~)
            if~isempty(elem.Type)
                strVal=dds.internal.simulink.Util.convertToStr(elem.getValue);
            else
                typeStr=h.getTypeStr(elem);

                strippedValue=dds.internal.simulink.Util.stripParenInStr(elem.ValueStr);

                splitValue=strsplit(strippedValue,'(::)|(\.)','DelimiterType','RegularExpression');
                enumElemName=splitValue{end};
                assert(~isempty(enumElemName));
                strVal=[typeStr,h.DependencyVisitor.TypeSep,enumElemName];
            end
            startElements{1}=['const ',...
            h.getTypeStr(elem),' ',...
            elem.Name,' = ',...
            strVal,';'];
            endElements={};
        end


        function[startElements,endElements]=processAlias(h,elem,~)
            if~isempty(elem.Type)&&h.objHasProperty(elem.Type,'MaxLength')
                maxLenStr=['<',h.getValueOrConstStr(elem.Type.MaxLength),'>'];
            else
                maxLenStr='';
            end
            startElements{1}=['typedef ',...
            h.getTypeStr(elem),...
            maxLenStr,...
            ' ',...
            dds.internal.getFullNameForType(elem,h.DependencyVisitor.TypeSep,false),...
            h.getDimensionStr(elem),';'];
            endElements={};
        end


        function[startElements,endElements]=processStruct(h,elem,~)
            startElements{1}=['struct ',elem.Name];
            if~isempty(elem.BaseRef)
                startElements{1}=[startElements{1},' : '...
                ,dds.internal.getFullNameForType(elem.BaseRef,h.DependencyVisitor.TypeSep,false)];...
            end
            startElements{2}='{';
            keys=elem.Members.keys;
            for i=1:elem.Members.Size
                member=elem.Members{keys(i)};
                if member.Key
                    if h.KeyAsComment
                        keyComment=' //@key';
                        keyMarker='';
                    else
                        keyComment='';
                        keyMarker='@Key ';
                    end
                else
                    keyComment='';
                    keyMarker='';
                end
                if~isempty(member.RoundTripInfo)&&member.RoundTripInfo.Optional

                    if~isempty(keyComment)
                        keyComment=[keyComment,' @optional'];%#ok<AGROW> 
                    else
                        keyComment=' //@optional';
                    end
                end
                typeStr=h.getTypeStr(member);
                if~isempty(member.Type)&&h.objHasProperty(member.Type,'MaxLength')&&~isempty(member.Type.MaxLength)
                    maxLenStr=['<',h.getValueOrConstStr(member.Type.MaxLength),'>'];
                else
                    maxLenStr='';
                end
                dimStr=h.getDimensionStr(member);
                startElements{2+i}=[h.SPACER,keyMarker,typeStr,maxLenStr,' ',member.Name,dimStr,';',keyComment];
            end
            startElements{end+1}=['}; //',elem.Name];

            endElements={};
        end


        function[startElements,endElements]=processModule(h,elem,elemFullName)
            startElements{1}=['module ',elem.Name];
            startElements{2}='{';
            endElements={};
            startToLookFor=[elemFullName,h.DependencyVisitor.TypeSep];
            children=h.Dependencies.TypeLibraries(cellfun(@(x)startsWith(x,startToLookFor),h.Dependencies.TypeLibraries));
            for idx=1:numel(children)
                [startElementsInner,endElementsInner]=h.processElement(children{idx});
                [startElements,endElements]=h.concatElements(startElements,endElements,startElementsInner,endElementsInner,h.SPACER);
            end
            startElements{end+1}=['}; //',elem.Name];
        end


        function typeStr=getTypeStr(h,elem)
            if~isempty(elem.Type)
                typeStr=h.getBasicTypeStr(elem.Type);
            else
                typeStr=dds.internal.getFullNameForType(elem.TypeRef,h.DependencyVisitor.TypeSep,false);%#referring as Mod::Mod2::Type
            end
            if h.isElemVarLen(elem)
                typeStr=['sequence< ',typeStr,' >'];
            end
        end




        function typeStr=getBasicTypeStr(~,type)
            allKindsType=type.getDDSType();
            str=allKindsType.char;
            typeStr=lower(strrep(str,'Type',''));

            assert(ismember(typeStr,{...
            'boolean','char8',...
            'int8','uint8',...
            'int16','uint16',...
            'int32','uint32',...
            'int64','uint64',...
            'float32','float64',...
            'string','wstring'}));
        end


        function dimStr=getDimensionStr(h,elem)
            dimStr='';
            if~isempty(elem.Dimension)&&~h.isElemVarLen(elem)
                dimStr='[';
                for i=1:elem.Dimension.CurLength.Size
                    lenElem=elem.Dimension.CurLength(i);
                    dimStr=[dimStr,h.getValueOrConstStr(lenElem)];%#ok<AGROW>
                    if i~=elem.Dimension.CurLength.Size
                        dimStr=[dimStr,']['];%#ok<AGROW>
                    end
                end
                dimStr=[dimStr,']'];
            end
        end


        function isVarLen=isElemVarLen(h,elem)
            isVarLen=false;
            if h.objHasProperty(elem.Container,'Annotations')
                theAnnon=dds.internal.simulink.Util.findOrCreateAnnnontationMember(elem.Container,false,elem.Name);
                if~isempty(theAnnon)
                    decoded=jsondecode(theAnnon.ValueStr);
                    if isfield(decoded,'Description')&&~isempty(decoded.Description)
                        isVarLen=~isempty(regexp(decoded.Description,'IsVarLen\s*=\s*1','once'));
                    end
                end
            end
        end

        function lenStr=getValueOrConstStr(h,lenElem)
            if~isempty(lenElem.ValueConst)


                lenStr=dds.internal.getFullNameForType(lenElem.ValueConst,h.DependencyVisitor.TypeSep,false);%#referring as Mod::Mod2::Type
            else
                lenStr=dds.internal.simulink.Util.convertToStr(lenElem.Value);
            end
        end


        function has=objHasProperty(~,obj,propertyName)
            has=any(cellfun(@(x)isequal(propertyName,x),properties(obj)));
        end

    end
end


