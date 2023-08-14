classdef SimulationOutput
























    properties(SetAccess=private,GetAccess=private)
        Data=struct;
        Metadata=[];
        FileSignatures=struct;
    end

    properties(Dependent,SetAccess=private)
SimulationMetadata
    end

    properties(SetAccess=private)
        ErrorMessage='';
    end

    methods(Hidden=true)
        function out=SimulationOutput(varargin)
            if nargin==0
                return;
            end


            Datas=struct;
            Metadatas=struct;


            if nargin>=2
                if~isempty(varargin{1})
                    Datas=varargin{1};
                end
                if~isempty(varargin{2})
                    Metadatas=varargin{2};

                end
            elseif nargin==1
                if~isempty(varargin{1})
                    Datas=varargin{1};
                end
            end


            nOut=numel(Datas);
            sizes=num2cell(size(Datas));
            out(sizes{:})=Simulink.SimulationOutput();

            if~iscell(Datas)

                out.Data=Datas;
                if nargin>=2
                    out.Metadata=Simulink.SimulationMetadata(Metadatas);
                    out=out.setError();
                end
                out=out.setFileSignatures();
            else

                assert(isequal(size(Datas),size(Metadatas)),...
                'Datas and Metadatas have different size');
                for idx=1:nOut
                    if~isempty(Datas{idx})
                        out(idx).Data=Datas{idx};
                    end

                    if~isempty(Metadatas{idx})
                        out(idx).Metadata=Simulink.SimulationMetadata(Metadatas{idx},false);
                        out(idx)=out(idx).setErrorNoCheck();
                    end
                end
                out=out.setFileSignatures();
            end
        end


        function n=numArgumentsFromSubscript(obj,s,context)
            try

                isWho=false;
                switch s(1).type
                case '.'
                    if obj.isPublicPropertyOrMethod(s(1).subs)

                        curIndex=1;
                        switch(s(1).subs)
                        case 'who'
                            isWho=true;
                            if context==matlab.mixin.util.IndexingContext.Expression
                                n=numel(obj);
                            else
                                n=0;
                            end
                        case 'disp'
                            n=0;
                        case{'getSimulationMetadata','SimulationMetadata'}
                            if numel(s)>=5&&(ischar(s(end).subs)||isstring(s(end).subs))
                                switch s(end).subs
                                case{'reportAsError','reportAsWarning','reportAsInfo'}
                                    n=0;
                                    return;
                                otherwise
                                    n=numel(obj);
                                end
                            else
                                n=numel(obj);
                            end
                        case 'setUserData'
                            n=1;


                            if numel(s)>2
                                curIndex=2;
                            end
                        case 'setUserString'
                            n=1;


                            if numel(s)>2
                                curIndex=2;
                            end
                        case 'get'
                            n=numel(obj);
                            if(length(s)>1)&&strcmp(s(2).type,'()')
                                curIndex=2;
                            end
                        case 'properties'
                            n=numel(obj);
                        case 'find'
                            n=numel(obj);
                            if(length(s)>1)&&strcmp(s(2).type,'()')
                                curIndex=2;
                            end
                        case 'isprop'
                            n=1;
                        otherwise

                            if length(s)==1||~strcmp(s(2).type,'()')
                                n=builtin('numArgumentsFromSubscript',obj,s(1),context);
                            else
                                n=builtin('numArgumentsFromSubscript',obj,s(1:2),context);
                                curIndex=2;
                            end
                        end



                        if length(s)>curIndex&&isWho==false
                            [temp{1:n}]=subsref(obj,s(1:curIndex));
                            num=n;
                            n=0;
                            for idx=1:num
                                n=n+numArgumentsFromSubscript(temp{idx},s(curIndex+1:end),context);
                            end
                        end
                        return;
                    else

                        s2=struct('type','.','subs','get');
                        s2(2)=struct('type','()','subs',{{s(1).subs}});
                        n=numArgumentsFromSubscript(obj,s2,context);

                        if(length(s)>1)
                            [temp{1:n}]=subsref(obj,s2);
                            num=n;
                            n=0;
                            for idx=1:num
                                n=n+numArgumentsFromSubscript(temp{idx},...
                                s(2:end),context);
                            end
                        end
                        return;
                    end
                case '()'


                    if length(s)==1
                        n=builtin('numArgumentsFromSubscript',obj,s,context);
                    elseif s(2).type=='.'
                        n=numArgumentsFromSubscript(subsref(obj,s(1)),...
                        s(2:end),context);
                    else
                        n=builtin('numArgumentsFromSubscript',obj,s,context);
                    end
                case '{}'


                    id='MATLAB:cellRefFromNonCell';
                    ME=MException(id,message(id).getString());
                    throwAsCaller(ME);
                end
            catch ME
                throwAsCaller(ME);
            end
        end

        function varargout=subsref(obj,s)
            try
                switch s(1).type
                case '.'
                    switch s(1).subs
                    case 'getInternalSimulationDataAndMetadataStructs'
                        [varargout{1:nargout}]=...
                        obj.getInternalSimulationDataAndMetadataStructs();
                        return;
                    end

                    isPublic=obj.isPublicPropertyOrMethod(s(1).subs);
                    if isPublic
                        n=numel(obj);
                        for idx=1:n
                            try
                                tmp=obj(idx).Data.(s(1).subs);%#ok
                                id='Simulink:Simulation:SimulationOutputShadowingPropOrMethod';
                                warning(id,DAStudio.message(id,s(1).subs));
                                break;
                            catch ME %#ok
                            end
                        end
                        switch s(1).subs
                        case 'who'
                            if nargout==0
                                builtin('subsref',obj,s);
                            else
                                [varargout{1:nargout}]=builtin('subsref',obj,s);
                            end
                        otherwise
                            [varargout{1:nargout}]=builtin('subsref',obj,s);
                        end
                    else
                        if length(s)==1
                            [varargout{1:nargout}]=obj.get(s.subs);
                        else

                            if(nargout==1)&&numel(obj)>1
                                id='MATLAB:index:expected_one_output_from_expression';
                                ME=MException(id,message(id,numel(obj)).getString());
                                throw(ME);
                            end
                            n=numel(obj);
                            [intermediate{1:n}]=obj.get(s(1).subs);
                            varargout={};


                            for idx=1:n


                                if n==1
                                    nOut=nargout;
                                else
                                    nOut=numArgumentsFromSubscript(intermediate{idx},s(2:end),...
                                    matlab.mixin.util.IndexingContext.Statement);
                                end



                                [temp{1:nOut}]...
                                =Simulink.internal.subsrefRecurser(intermediate{idx},s(2:end));
                                varargout=[varargout,temp];%#ok
                            end
                        end


                        if numel(varargout)<nargout
                            id='MATLAB:needMoreRhsOutputs';
                            ME=MException(id,message(id).getString());
                            throwAsCaller(ME);
                        end
                    end
                case '()'
                    if length(s)==1

                        [varargout{1:nargout}]=builtin('subsref',obj,s);
                    else

                        intermediate=builtin('subsref',obj,s(1));
                        [varargout{1:nargout}]=Simulink.internal.subsrefRecurser(...
                        intermediate,s(2:end));
                    end
                case '{}'
                    id='MATLAB:cellRefFromNonCell';
                    ME=MException(id,message(id).getString());
                    throw(ME);
                otherwise
                    error('Not a valid indexing expression')
                end
            catch ME
                throwAsCaller(ME)
            end
        end

        function obj=subsasgn(obj,s,varargin)
            try
                switch s(1).type
                case '.'

                    if~isfield(obj.Data,s(1).subs)

                        [isPublic,isGetOnly]=obj.isPublicPropertyOrMethod(s(1).subs);
                        if isGetOnly
                            if strcmp(s(1).subs,'SimulationMetadata')&&length(s)>1&&s(2).type=='.'...
                                &&(strcmp(s(2).subs,'UserData')||strcmp(s(2).subs,'UserString'))
                                s(1).subs='Metadata';
                                obj=builtin('subsasgn',obj,s,varargin{:});
                                return;
                            end
                            id='MATLAB:class:SetProhibited';
                            ME=MException(id,DAStudio.message(id,s(1).subs,'Simulink.SimulationOutput'));
                            throw(ME);
                        end
                        if(isPublic)
                            id='MATLAB:index:assignmentToTemporary';
                            ME=MException(id,message(id,s(1).subs).getString());
                            throwAsCaller(ME);
                        end
                    end


                    if length(s)==1
                        obj.Data.(s(1).subs)=varargin{:};

                    else
                        [temp{1:nargout}]=Simulink.internal.subsasgnRecurser(...
                        obj.Data.(s(1).subs),s(2:end),varargin{:});
                        [obj.Data.(s(1).subs)]=temp{:};
                    end
                case '()'
                    if isempty(obj)&&isnumeric(obj)&&length(s)==1
                        obj=Simulink.SimulationOutput.empty(0);
                    end

                    if length(s)==1
                        obj=builtin('subsasgn',obj,s,varargin{:});
                    elseif s(2).type=='.'
                        intermediate=builtin('subsref',obj,s(1));
                        n=numel(intermediate);
                        if numel(varargin)==1
                            for idx=1:n
                                intermediate(idx)=Simulink.internal.subsasgnRecurser(...
                                intermediate(idx),s(2:end),varargin{:});
                            end
                        else
                            for idx=1:n
                                intermediate(idx)=Simulink.internal.subsasgnRecurser(...
                                intermediate(idx),s(2:end),varargin{idx});
                            end
                        end


                        obj=Simulink.internal.subsasgnRecurser(obj,s(1),intermediate);

                    else

                        obj=builtin('subsasgn',obj,s,varargin{:});
                    end
                case '{}'
                    id='MATLAB:cellRefFromNonCell';
                    ME=MException(id,message(id).getString());
                    throw(ME);
                otherwise
                    error('Not a valid indexing expression');
                end
            catch ME

                if strcmp(ME.identifier,'MATLAB:AddField:InvalidFieldName')
                    id='Simulink:Simulation:InvalidPropertyName';
                    ME=MException(id,message(id,ME.arguments{1}).getString());
                end
                throwAsCaller(ME)
            end
        end


        function obj=setDatasetRefMatFileLocation(obj,location)
            obj.FileSignatures=struct();
            names=fieldnames(obj.Data);
            nFields=numel(names);
            for idx=1:nFields

                if strcmp(class(obj.Data.(names{idx})),'Simulink.SimulationData.DatasetRef')%#ok
                    obj.Data.(names{idx})=Simulink.SimulationData.DatasetRef(location,names{idx});
                    obj.FileSignatures.(names{idx})=obj.Data.(names{idx}).fileSignature();
                end
            end
        end

        function obj=setCoverageDataFileLocation(obj,location)

            names=fieldnames(obj.Data);
            nFields=numel(names);
            for idx=1:nFields

                if strcmp(class(obj.Data.(names{idx})),'cvdata')%#ok
                    obj.Data.(names{idx})=cvdata(location);
                elseif strcmp(class(obj.Data.(names{idx})),'cv.cvdatagroup')%#ok
                    obj.Data.(names{idx})=cv.cvdatagroup(location);
                end

            end
        end

    end

    methods(Access=public)
        function varargout=who(simOut)






            n=numel(simOut);
            varNames=cell(n,1);
            for idx=1:n
                varNames{idx}=sort(fieldnames(simOut(idx).Data));
            end
            if nargout>0
                varargout=varNames;
            else
                for idx=1:n
                    if isempty(varNames{idx})
                        disp(DAStudio.message(...
                        'Simulink:tools:SimulationOutputWhoEmpty'));
                    else
                        disp(DAStudio.message(...
                        'Simulink:tools:SimulationOutputWhoHeading'));
                        fprintf(1,'\n');
                        varStr='    ';
                        for i=1:numel(varNames{idx})
                            varStr=[varStr,sprintf('%s    ',varNames{idx}{i})];%#ok
                        end
                        disp(varStr);
                    end
                    fprintf(1,'\n');
                end
            end
        end



        function varargout=get(simOut,var)






            if nargin==2
                n=numel(simOut);
                if n>0
                    varargout=cell(n,1);
                    for idx=1:n
                        try
                            varargout{idx}=simOut(idx).Data.(var);

                            if strcmp(class(varargout{idx}),'Simulink.SimulationData.DatasetRef')%#ok
                                if~isfield(simOut.FileSignatures,var)||...
                                    simOut.FileSignatures.(var)~=varargout{idx}.fileSignature()
                                    id='Simulink:Simulation:InvalidDatasetRefInSimOut';
                                    warning(id,DAStudio.message(id,var));
                                    varargout{idx}=[];
                                end
                            end
                        catch ME
                            if strcmp(ME.identifier,'MATLAB:nonExistentField')
                                varargout{idx}=[];
                                warning(ME.identifier,'%s',ME.message);
                            else
                                rethrow(ME);
                            end
                        end
                    end
                else
                    varargout{1}=[];
                end
            else
                [varargout{1:nargout}]=who(simOut);
            end
        end


        function varargout=find(simOut,var)





            tempOut=who(simOut);
            if nargin==2
                matches=strcmp(tempOut,var);
                if any(matches)
                    [varargout{1:nargout}]=simOut.get(tempOut{matches});
                else
                    varargout{1}=[];
                end
            else
                [varargout{1:nargout}]=tempOut;
            end
        end



        function out=eq(simOut,simOut2)
            out=isequal(simOut,simOut2);
        end


        function out=isequal(simOut,simOut2)
            out=false;
            if(isa(simOut,class(simOut2))&&isa(simOut2,class(simOut)))&&...
                (all(isequal(size(simOut),size(simOut2)))==true)
                out=true;
                for ind=1:numel(simOut)
                    out=isequal(simOut(ind).Data,simOut2(ind).Data);
                    if out==false
                        break;
                    end
                end
            end
        end


        function out=isequaln(simOut,simOut2)
            out=false;
            if(isa(simOut,class(simOut2))&&isa(simOut2,class(simOut)))&&...
                (all(isequal(size(simOut),size(simOut2)))==true)
                out=true;
                for ind=1:numel(simOut)
                    out=isequaln(simOut(ind).Data,simOut2(ind).Data);
                    if out==false
                        break;
                    end
                end
            end
        end

        function varargout=plot(this)





            ret=cell(1,nargout);
            [ret{:}]=Simulink.sdi.plot(this,'SimulationOutput');
            varargout=ret;
        end

    end

    methods
        function varargout=getSimulationMetadata(simOut)






            n=numel(simOut);
            varargout=cell(n,1);
            for idx=1:n
                varargout{idx}=simOut(idx).Metadata;
            end
        end

        function simOut=setUserData(simOut,uData)








            simOut.throwIfHasEmptyMetadata('UserData');

            n=numel(simOut);
            for idx=1:n
                simOut(idx).Metadata.UserData=uData;
            end
        end

        function simOut=setUserString(simOut,uString)








            simOut.throwIfHasEmptyMetadata('UserString');

            n=numel(simOut);
            for idx=1:n
                simOut(idx).Metadata.UserString=uString;
            end
        end

        function simOut=removeProperty(simOut,propName)






            n=numel(simOut);


            dataFieldExists=true;
            for idx=1:n
                if~isfield(simOut(idx).Data,propName)
                    dataFieldExists=false;
                    break
                end
            end



            if~dataFieldExists
                [isPublic,isGetOnly]=simOut.isPublicPropertyOrMethod(propName);
                if isGetOnly||isPublic
                    id='MATLAB:class:SetProhibited';
                    ME=MException(id,DAStudio.message(id,propName,'Simulink.SimulationOutput'));
                    throw(ME);
                end


                id='MATLAB:noSuchMethodOrField';
                ME=MException(id,DAStudio.message(id,propName,'Simulink.SimulationOutput'));
                throw(ME);
            end


            for idx=1:n
                simOut(idx).Data=rmfield(simOut(idx).Data,propName);
            end
        end

        function m=get.SimulationMetadata(obj)
            m=obj.Metadata;
        end
    end

    methods(Hidden=true)


        function varargout=properties(simOut)
            n=numel(simOut);
            if n==0
                f1=fieldnames(simOut);
                varargout{1}=sort({f1{:}})';
                return;
            else
                varargout=cell(n,1);
                for idx=1:n
                    f1=fieldnames(simOut(idx));
                    f2=fieldnames(simOut(idx).Data);
                    varargout{idx}=sort({f1{:},f2{:}})';%#ok
                end
            end
        end


        function val=isprop(simOut,prop)
            n=numel(simOut);
            if n==0
                val=logical.empty();
                return;
            else
                val=arrayfun(@(out)or(any(strcmp(fieldnames(out),prop)),...
                isfield(out.Data,prop)),simOut);
                return;
            end
        end



        function simOut=setMetadata(simOut,val)
            if numel(simOut)>1
                id='Simulink:Simulation:SimulationOutputSetMetadataArray';
                ME=MException(id,DAStudio.message(id));
                throw(ME);
            end
            if isa(val,'Simulink.SimulationMetadata')
                simOut.Metadata=val;
            else
                simOut.Metadata=Simulink.SimulationMetadata(val);
            end
            simOut=simOut.setError();
        end

        function disp(simOut)
            hotlinks=feature('hotlinks');
            if(numel(simOut)~=1)
                disp([sizeStr(size(simOut)),' ',...
                DAStudio.message(...
                'Simulink:tools:SimulationOutputArrDispHeading')]);
                fprintf(1,'\n');
            else
                name='Simulink.SimulationOutput';
                if hotlinks
                    fprintf(1,'  <a href="matlab: help %s">%s</a>:\n',...
                    name,name);
                else
                    fprintf(1,'  %s:',name);
                end

                fprintf(1,'\n');
                dataFieldNames=fieldnames(simOut.Data);
                fieldNames=fieldnames(simOut);
                fieldNames={dataFieldNames{:},fieldNames{:}};%#ok

                nFields=numel(fieldNames);
                maxNLen=0;
                for idx=1:nFields
                    maxNLen=max(numel(fieldNames{idx}),maxNLen);
                end
                maxNLen=maxNLen+4;

                if~isempty(simOut.Data)
                    nData=numel(dataFieldNames);
                    for idx2=1:nData
                        name=dataFieldNames{idx2};
                        str1=sprintf('%s:',name);
                        numSpace=maxNLen-length(name);
                        str2=repmat(' ',1,numSpace);
                        fprintf(1,'%s %s %s ',str2,str1,...
                        simOut.locGetArrayStr(simOut.Data.(name)));
                        if strcmp(class(simOut.Data.(name)),'Simulink.SimulationData.DatasetRef')%#ok
                            if~isfield(simOut.FileSignatures,name)||...
                                simOut.Data.(name).fileSignature()~=simOut.FileSignatures.(name)
                                fprintf(1,'%s',...
                                DAStudio.message('Simulink:Simulation:InvalidDatasetRefDisp'));
                            end
                        end
                        fprintf('\n');
                    end
                else
                    disp(DAStudio.message(...
                    'Simulink:tools:SimulationOutputDispEmpty'));
                end

                fprintf(1,'\n');


                name='SimulationMetadata';
                str1=sprintf('%s:',name);
                numSpace=maxNLen-length(name);
                str2=repmat(' ',1,numSpace);
                fprintf(1,'%s %s %s \n',str2,str1,...
                simOut.locGetArrayStr(simOut.Metadata));
                name='ErrorMessage';
                str1=sprintf('%s:',name);
                numSpace=maxNLen-length(name);
                str2=repmat(' ',1,numSpace);
                fprintf(1,'%s %s %s \n',str2,str1,...
                simOut.locGetArrayStr(simOut.ErrorMessage));

            end
            fprintf(1,'\n');
        end


        function out=getElementNames(simOut)

            out=fieldnames(simOut.Data);
        end



        function[simData,simMetadata]=getInternalSimulationDataAndMetadataStructs(simOut)
            simData={simOut.Data};
            mds={simOut.SimulationMetadata};
            simMetadata=cell(1,numel(simOut));
            for i=1:numel(simOut)
                if isempty(mds{i})
                    simMetadata{i}=[];
                else
                    simMetadata{i}=mds{i}.getInternalMetadataStruct();
                end
            end
        end
    end

    methods(Access=private)


        function throwIfHasEmptyMetadata(simOut,fName)
            if any(cellfun('isempty',{simOut.Metadata}))
                id='Simulink:Simulation:SimulationOutputContainsEmptyMetadata';
                ME=MException(id,message(id,fName).getString());
                throwAsCaller(ME);
            end
        end
    end

    methods(Hidden=true,Access=private,Static=true)


        function str=locGetArrayStr(val)
            if(isempty(val)&&isa(val,'double'))
                str='[]';
            else
                str=sprintf('%dx',size(val));
                str=sprintf('[%s %s]',str(1:end-1),class(val));
            end
        end







        function[isPublic,isGetOnly]=isPublicPropertyOrMethod(name)
            isPublic=true;
            isGetOnly=false;
            switch name


            case{'SimulationMetadata',...
                'ErrorMessage'}
                isGetOnly=true;


            case{'eq',...
                'find',...
                'get',...
                'getSimulationMetadata',...
                'isequal',...
                'isequaln',...
                'plot',...
                'setUserData',...
                'setUserString',...
                'who',...
                'removeProperty'}



            case{'setDatasetRefMatFileLocation',...
                'subsasgn',...
                'subsref',...
                'numArgumentsFromSubscript',...
                'SimulationOutput',...
                'getElementNames',...
                'disp',...
                'setMetadata',...
                'properties',...
                'loadobj',...
                'empty',...
                'getInternalSimulationDataAndMetadataStructs',...
                'isprop',...
                'setCoverageDataFileLocation'}


            otherwise
                isPublic=false;
            end
        end


        function privateCheck(name,isGet)

            [isPublic,isGetOnly]=Simulink.SimulationOutput.isPublicPropertyOrMethod(name);
            if~isPublic
                id='MATLAB:noSuchMethodOrField';
                ME=MException(id,DAStudio.message(id,name,'Simulink.SimulationOutput'));
                throw(ME);
            elseif~isGet&&isGetOnly
                id='MATLAB:class:SetProhibited';
                ME=MException(id,DAStudio.message(id,name,'Simulink.SimulationOutput'));
                throw(ME);
            end
        end

    end

    methods(Static=true,Hidden=true)


        function obj=loadobj(var)
            if isstruct(var)
                assert(isfield(var,'Data'));
                if isfield(var,'Metadata')
                    obj=Simulink.SimulationOutput(var.Data,var.Metadata);
                else
                    obj=Simulink.SimulationOutput(var.Data);
                end
            else
                assert(isa(var,'Simulink.SimulationOutput'));
                obj=var.setError();
            end
        end

    end

    methods(Access=private)



        function out=setError(out)
            if~isempty(out.Metadata)&&isprop(out.Metadata,'ExecutionInfo')...
                &&~isempty(out.Metadata.ExecutionInfo)...
                &&isfield(out.Metadata.ExecutionInfo,'ErrorDiagnostic')...
                &&~isempty(out.Metadata.ExecutionInfo.ErrorDiagnostic)
                out.ErrorMessage=out.Metadata.ExecutionInfo.ErrorDiagnostic.Diagnostic.getReport();
            else
                out.ErrorMessage='';
            end
        end



        function out=setErrorNoCheck(out)
            if~isempty(out.Metadata.ExecutionInfo.ErrorDiagnostic)
                out.ErrorMessage=out.Metadata.ExecutionInfo.ErrorDiagnostic.Diagnostic.getReport();
            else
                out.ErrorMessage='';
            end
        end


        function out=setFileSignatures(out)
            n=numel(out);
            for idx=1:n
                names=fieldnames(out(idx).Data);
                nFields=numel(names);
                for idx2=1:nFields

                    if strcmp(class(out(idx).Data.(names{idx2})),...
                        'Simulink.SimulationData.DatasetRef')%#ok
                        out(idx).FileSignatures.(names{idx2})=...
                        out(idx).Data.(names{idx2}).fileSignature();
                    end
                end
            end
        end

    end


end


function szStr=sizeStr(sz)
    szStr='';
    for i=1:length(sz)-1
        szStr=[szStr,num2str(sz(i)),'x'];%#ok
    end
    szStr=[szStr,num2str(sz(i+1))];
end

