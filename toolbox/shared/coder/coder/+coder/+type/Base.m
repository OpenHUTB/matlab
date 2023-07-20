





classdef(Abstract)Base<matlab.mixin.CustomDisplay


    properties(Access=public)
        Size;
        VarDims;
    end

    properties(Access=private)


        CoderType;
    end

    methods(Access=protected,Hidden=true)
        function obj=initialize(obj)


        end

        function coderType=validateCoderType(~,coderType)




        end
    end

    methods(Static,Hidden=true)



        function mp=map()
            mp=struct();
        end















        function c=constant()
            c=struct();
        end







        function h=homogeneous()
            h=struct();
        end









        function resize=supportsCoderResize()

            resize.supported=false;




            resize.property='';



            resize.callback='';
        end
    end

    methods(Access=public,Hidden=true)
        function obj=union(obj,obj2,varargin)


            if isa(obj2,'coder.type.Base')
                type2=obj2.getCoderType(false);
            else
                type2=obj2;
            end

            try
                unionedType=obj.getCoderType(false).union(type2);
            catch me
                throwAsCaller(me);
            end


            if nargin==3
                unionedType=varargin{1}(unionedType);
            end


            obj=obj.setCoderType(unionedType);
        end
    end

    methods(Access=public,Sealed=true)




        function obj=Base(coderType)
            obj.enforceCoderClassType(coderType);
            obj=obj.init(coderType);
        end

        function coderType=getCoderType(obj,varargin)


            if isequal(nargin,2)&&~varargin{1}
                coderType=obj.CoderType;
            else
                coderType=obj.validateCoderType(obj.CoderType);
            end
        end
    end

    methods(Access=public,Sealed=true,Hidden=true)
        function obj=updateSize(obj)
            obj=obj.initializeSize();
        end
    end

    methods(Static,Hidden=true,Sealed=true)
        function enabled=isEnabled(target)


            coder.typeof({1});
            if isequal(target,'GUI')
                enabled=slf_feature('get','CustomCoderTypeGUI');
            elseif isequal(target,'CLI')
                enabled=slf_feature('get','CustomCoderTypeCLI');
            else
                error(message('Coder:common:CoderTypeInvalidFeatureSwitch'));
            end
        end

        function setEnabled(target,enabled)


            coder.typeof({1});
            if isequal(target,'GUI')
                slf_feature('set','CustomCoderTypeGUI',enabled);
            elseif isequal(target,'CLI')
                slf_feature('set','CustomCoderTypeCLI',enabled);
            elseif isequal(target,'ALL')
                slf_feature('set','CustomCoderTypeGUI',enabled);
                slf_feature('set','CustomCoderTypeCLI',enabled);
            end
        end

        function coderType=getCoderTypeCOS(obj)

            coderType=obj.getCoderType();
        end

        function val=hasCustomCoderType(className)
            className=coder.internal.getRedirectedClassName(className);
            if slf_feature('get','CustomCoderTypeCLI')
                val=coder.internal.hasPublicStaticMethod(className,'matlabCodegenTypeof');
            else
                val=false;
            end
        end



        function name=getCustomCoderTypeName(coderType)
            className=coderType.ClassName;
            className=coder.internal.getRedirectedClassName(className);
            if coder.type.Base.hasCustomCoderType(className)
                name=eval([className,'.matlabCodegenTypeof(coderType)']);
            else
                name='';
            end
        end


        function props=getAnnotatedProperties(obj,annotation)
            supportedAnnotations={'constant','homogeneous'};
            if~any(strcmp(supportedAnnotations,annotation))
                error(message('Coder:common:CoderTypeInvalidAnnotation',...
                strjoin(supportedAnnotations,', ')));
            end

            typeName=coder.type.Base.getCustomCoderTypeName(obj);
            tmp=eval([typeName,'.',annotation,'()']);
            props=struct();

            flds=fieldnames(tmp);
            for i=1:numel(flds)


                if~isequal(tmp.(flds{i}),false)
                    props.(flds{i})=tmp.(flds{i});
                end
            end
        end




        function type=applyCustomCoderType(coderType)
            if isa(coderType,'coder.ClassType')
                customClassName=coder.type.Base.getCustomCoderTypeName(coderType);

                if~isempty(customClassName)
                    customCtor=str2func(customClassName);
                    type=customCtor(coderType);
                else
                    type=coderType;
                end
            else
                type=coderType;
            end
        end
    end

    methods(Hidden=true,Sealed=true)
        function obj=setCoderType(obj,coderType,varargin)

            obj.enforceCoderClassType(coderType);

            if isequal(nargin,3)&&~varargin{1}

                obj.CoderType=coderType;
            else

                coderType=obj.validateCoderType(coderType);
                obj=obj.initFromCoderType(coderType);
            end
        end


        function val=contains(obj,coderType)
            type1=obj.getCoderType(false);
            if isa(coderType,'coder.type.Base')
                type2=coderType.getCoderType(false);
            else
                type2=coderType;
            end

            val=type1.contains(type2);
        end

        function dialog(obj)

            dstack=dbstack;
            if numel(dstack)>=2&&dstack(2).name=="openvar"
                name=evalin('caller',"name");
                coder.internal.showCoderTypeEditorForTypeObject(obj,name);
            end
        end

        function obj=subsasgn(obj,access,val)
            pName=access(1).subs;

            try
                if obj.isSizeAssignment(pName)
                    if obj.supportsCoderResize().supported



                        szAssignment=isequal(pName,'Size');

                        if szAssignment
                            if isnumeric(val)
                                sz=obj.assignVector(obj.Size,val,access);
                                vd=obj.VarDims;
                            else
                                error(message('Coder:common:CoderTypeInvalidSize'));
                            end
                        else
                            if islogical(val)||isnumeric(val)
                                vd=obj.assignVector(obj.VarDims,val,access);
                                sz=obj.Size;
                            else
                                error(message('Coder:common:CoderTypeInvalidVarDims'));
                            end
                        end


                        if~isequal(size(sz),size(vd))
                            if szAssignment
                                vd=isinf(sz);
                            elseif isscalar(vd)


                                vd=repmat(vd,[1,numel(vd)]);
                            else
                                error(message('Coder:common:CoderTypeInvalidSizeVector'));
                            end
                        elseif szAssignment
                            vd=isinf(sz);
                        end



                        obj=coder.resize(obj,sz,vd);
                    else
                        error(message('Coder:common:CoderTypeResizeNotSupported',class(obj)));
                    end
                elseif~isequal(access(1).type,'.')
                    error(message('Coder:common:CoderTypeComplexIndex'));
                else
                    if isa(obj.(pName),'coder.type.Base')




                        access=access(2:end);

                        if~isempty(access)
                            cct=obj.(pName);
                            val=cct.subsasgn(access,val);
                        end
                    end




                    if numel(access)>1
                        access=access(2:end);
                    else
                        access={};
                    end

                    rName=obj.getRedirectedPropertyName(pName,true);
                    obj=obj.setTypeProperty(pName,rName,val,access,true);
                end
            catch me
                throwAsCaller(me);
            end
        end


        function props=getTypeProperties(obj)
            props=properties(obj);
            props(strncmpi(props,'Size',strlength('Size')))=[];
            props(strncmpi(props,'VarDims',strlength('Size')))=[];
        end

        function props=getProperties(obj)


            props=struct();
            pNames=obj.getTypeProperties();
            for i=1:numel(pNames)
                props.(pNames{i})=obj.(pNames{i});
            end
        end


        function obj=setSize(obj,pName,val)


            if obj.isSizeAssignment(pName)
                obj.(pName)=val;
            else
                error(message('Coder:common:CoderTypeSizeAssignmentError'));
            end
        end


        function obj=homogenize(obj)
            flds=fieldnames(obj);
            access=struct('type','.');
            for i=1:numel(flds)

                val=obj.enforceHomogeneousVal(flds{i},obj.(flds{i}));


                if~isequal(val,obj.(flds{i}))
                    access.subs=flds{i};
                    obj=obj.subsasgn(access,val);
                end
            end
        end



        function type=applyConstantAnnotations(type,fieldValues)%#ok<INUSD>
            constants=coder.type.Base.getAnnotatedProperties(type.getCoderType(false),'constant');
            flds=fieldnames(constants);

            for i=1:numel(flds)
                try

                    access=struct('type','.','subs',flds{i});



                    val=eval(['fieldValues.',constants.(flds{i}),';']);%#ok<EVLDOT> 
                    type=type.subsasgn(access,coder.Constant(val));
                catch
                    if ischar(constants.(flds{i}))||isstring(constants.(flds{i}))
                        error(message('Coder:common:CoderTypeFailedConstantInitialization',flds{i}));
                    end
                end
            end
        end
    end

    methods(Access=protected,Hidden=true,Sealed=true)
        function obj=initFromCoderType(obj,coderType,varargin)
            obj.CoderType=coderType;
            obj=obj.initializeSize();
            obj=obj.initializeProperties();
        end




        function obj=initializeProperties(obj)
            props=obj.getTypeProperties();

            for i=1:numel(props)
                obj.(props{i})=obj.getRedirectedPropertyValue(props{i});

                if iscell(obj.(props{i}))
                    for ii=1:numel(obj.(props{i}))
                        if isa(obj.(props{i}){ii},'coder.ClassType')
                            pVal=coder.type.Base.applyCustomCoderType(obj.(props{i}){ii});
                            obj.(props{i}){ii}=pVal;
                        end
                    end
                elseif isa(obj.(props{i}),'coder.ClassType')
                    obj.(props{i})=coder.type.Base.applyCustomCoderType(obj.(props{i}));
                end
            end
        end


        function displayScalarObject(obj)

            flds=obj.getTypeProperties();

            disp("   "+class(obj));
            disp("     "+obj.printSize(obj.Size,obj.VarDims)+" "+obj.CoderType.ClassName);

            output=[];
            lhsFieldWidth=0;

            for i=1:numel(flds)
                pValue=obj.(flds{i});
                if isa(pValue,'coder.Constant')||isa(pValue,'coder.internal.MxArrayConstant')
                    t=strtrim(evalc('disp(pValue.Value);'));
                    t=regexprep(t,'\n\n+','\n');


                    tt=splitlines(t);
                    if length(tt)>4
                        tt=tt(1:4);
                        tt(end+1)={'...'};%#ok<AGROW>
                        t=join(tt,newline);
                    end
                elseif isa(pValue,'coder.type.Base')
                    t=obj.typePrettyPrint(pValue);
                elseif isa(pValue,'coder.Type')
                    t=obj.typePrettyPrint(pValue);
                else

                    t=class(pValue);
                end


                output(end+1).lhs=string(flds{i});%#ok<AGROW>
                output(end).rhs=string(t);

                if strlength(output(end).lhs)>lhsFieldWidth
                    lhsFieldWidth=strlength(output(end).lhs);
                end
            end

            formatString="\t%+"+string(lhsFieldWidth)+"s : %s\n";

            for i=1:numel(output)


                rhsSplit=splitlines(output(i).rhs);
                lhs=output(i).lhs;
                printerString=formatString;

                for j=1:numel(rhsSplit)
                    fprintf(printerString,lhs,strtrim(rhsSplit(j)));


                    lhs="";
                    printerString=strrep(printerString,':',' ');
                end
            end

            if~isempty(inputname(1))
                fprintf('\n    %s\n',message('Coder:configSet:EditTypeObj',inputname(1)));
            end
        end

        function pVal=enforceConstVal(obj,aName,pVal)
            constants=obj.constant();
            if~isempty(constants)&&isfield(constants,aName)&&~isequal(constants.(aName),false)
                if~isa(pVal,'coder.Constant')
                    try
                        pVal=coder.Constant(pVal);
                    catch me
                        throwAsCaller(addCause(MException(message('Coder:common:CoderTypeRequiredConstant',aName)),me));
                    end
                end
            end
        end

        function pVal=enforceHomogeneousVal(obj,pName,pVal)
            homogeneous=obj.homogeneous();

            if isfield(homogeneous,pName)&&ismethod(pVal,'makeHomogeneous')
                pVal=pVal.makeHomogeneous();
            end
        end

        function pVal=enforcePropertyConstraints(obj,pName,pVal)


            pVal=obj.enforceConstVal(pName,pVal);

            if~isa(pVal,'coder.Type')
                pVal=coder.typeof(pVal);
            end


            pVal=obj.enforceHomogeneousVal(pName,pVal);
        end

        function obj=setTypeProperty(obj,aName,pName,pVal,access,varargin)



            pVal=obj.enforcePropertyConstraints(aName,pVal);

            if isa(pName,'function_handle')
                obj=pName(obj,pVal,access);
                handle=obj.getRedirectedPropertyValue(aName);
            else

                handle=eval(['obj.CoderType.',pName,';']);%#ok<EVLDOT> 


                if~isempty(access)
                    handle=subsasgn(handle,access,pVal);
                else
                    handle=pVal;
                end

                if isa(handle,'coder.type.Base')
                    coderHandle=handle.getCoderType();%#ok<NASGU>
                else
                    coderHandle=handle;%#ok<NASGU>
                end


                eval(['obj.CoderType.',pName,'= coderHandle;']);%#ok<EVLDOT> 
            end

            obj.(aName)=coder.type.Base.applyCustomCoderType(handle);
        end
    end

    methods(Access=private)

        function enforceCoderClassType(~,coderType)
            if~isa(coderType,'coder.ClassType')
                error(message('Coder:common:CoderTypeInitializer'));
            end
        end


        function vector=assignVector(~,oldVal,val,access)
            if numel(access)==1

                vector=val;
            else
                vector=subsasgn(oldVal,access(2:end),val);
            end
        end


        function yes=isSizeAssignment(~,pName)
            if isequal(pName,'Size')||isequal(pName,'VarDims')
                yes=true;
            else
                yes=false;
            end
        end






        function s=printSize(~,varargin)
            if nargin==3

                if numel(varargin{1})==numel(varargin{2})


                    vd=string(varargin{2});
                    vd(varargin{2})=":";
                    vd(~varargin{2})="";
                    s=strcat(vd,string(varargin{1}));
                else
                    error(message('Coder:common:CoderTypeInvalidSizeVector'));
                end
            else

                s=string(varargin{1});
            end

            s=strtrim(strjoin(s,'x'));
        end


        function s=typePrettyPrint(obj,coderType)
            cl='';

            if isa(coderType,'coder.type.Base')
                cl=class(coderType);
                sz=coderType.Size;
                vd=coderType.VarDims;
            elseif isa(coderType,'coder.Type')
                if isa(coderType,'coder.CellType')
                    if coderType.isHomogeneous()
                        cl='homogeneous ';
                    else
                        cl='heterogeneous ';
                    end
                end

                cl=[cl,coderType.ClassName];
                sz=coderType.SizeVector;
                vd=coderType.VariableDims;
            else
                error(['Unknown type ',class(coderType)]);
            end

            sz=obj.printSize(sz,vd);
            s=sz+" "+cl;
        end

        function obj=init(obj,coderType)
            obj=obj.initFromCoderType(coderType);



            oldTypes=obj.snapshotTypes();


            obj=obj.initialize();


            obj=obj.synchronizeProperties(oldTypes);
        end

        function types=snapshotTypes(obj)
            props=obj.getTypeProperties();
            types=containers.Map;

            for i=1:numel(props)
                types(props{i})=obj.(props{i});
            end
        end

        function obj=synchronizeProperties(obj,oldTypes)
            props=obj.getTypeProperties();

            for i=1:numel(props)
                if~isequal(obj.(props{i}),oldTypes(props{i}))
                    redirectedName=obj.getRedirectedPropertyName(props{i},true);
                    obj=obj.setTypeProperty(props{i},redirectedName,obj.(props{i}),[]);
                end
            end
        end


        function obj=initializeSize(obj)
            resize=obj.supportsCoderResize();

            if resize.supported&&...
                (isfield(resize,'property')&&~isempty(resize.property))
                try

                    if startsWith(resize.property,'Properties.')
                        resizePropertyName=resize.property;
                    else


                        if isprop(obj,resize.property)
                            resizePropertyName=obj.getRedirectedPropertyName(resize.property,false);
                        else
                            resizePropertyName=['Properties.',resize.property];
                        end
                    end

                    pVal=eval(['obj.CoderType.',resizePropertyName]);%#ok<EVLDOT> 

                    if isa(pVal,'coder.Constant')
                        obj.Size=pVal.Value;
                        obj.VarDims=isinf(obj.Size);
                    else
                        obj.Size=pVal.SizeVector;
                        obj.VarDims=pVal.VariableDims;
                    end
                catch
                    error(message('Coder:common:CoderTypeFailedInitialization'));
                end
            else
                obj.Size=obj.CoderType.SizeVector;
                obj.VarDims=obj.CoderType.VariableDims;
            end
        end

        function val=getRedirectedPropertyValue(obj,pName)
            redirectedName=obj.getRedirectedPropertyName(pName,false);

            try
                val=eval(['obj.CoderType.',redirectedName]);%#ok<EVLDOT> 
            catch me

                error(message('Coder:common:CoderTypeInvalidPropertyName',redirectedName));
            end
        end





        function name=getRedirectedPropertyName(obj,pName,setter)
            mp=obj.map();

            if isempty(fieldnames(mp))||~isfield(mp,pName)
                name=obj.getDefaultPropertyMappingName(pName);
            else
                pEntry=mp.(pName);
                if~iscell(pEntry)


                    if isa(pEntry,'function_handle')
                        name=feval(pEntry);
                    elseif ischar(pEntry)
                        name=obj.getDefaultPropertyMappingName(pEntry);
                    else
                        error(message('Coder:common:CoderTypeInvalidPropertyMapping'));
                    end
                else




                    name=pEntry{1+setter};

                    if~isa(name,'function_handle')
                        name=obj.getDefaultPropertyMappingName(pEntry{1+setter});
                    end
                end
            end
        end




        function name=getDefaultPropertyMappingName(obj,pName)
            if isa(obj.CoderType,'coder.ClassType')
                prefix='Properties';
            else
                error(message('Coder:common:CoderTypeInvalidDefaultPropertyMapping',pName));
            end

            name=[prefix,'.',pName];
        end
    end
end
