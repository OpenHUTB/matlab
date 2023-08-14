classdef FixPtTypeSpec<handle

    properties
IsInteger
ProposedType
RoundingMethod
OverflowAction
fimath
    end

    properties(Constant,Hidden)
        LEGAL_ROUNDING_METHODS=coder.FixPtTypeSpec.getLegalRoudingMethods();
        LEGAL_OVERFLOW_ACTIONS=coder.FixPtTypeSpec.getLegalOverflowActions();
    end

    methods
        function this=FixPtTypeSpec

            this.IsInteger=false;
            this.ProposedType='';
            this.RoundingMethod='Floor';
            this.OverflowAction='Wrap';
            this.fimath=[];


            this.IsIntegerSet=false;
            this.ProposedTypeSet=false;
            this.RoundingMethodSet=false;
            this.OverflowActionSet=false;
            this.FimathSet=false;
        end

        function disp(this)

            fprintf(['  <a href="matlab:helpPopup coder.FixPtTypeSpec">FixPtTypeSpec</a> with properties:',newline]);



            propList={'IsInteger','ProposedType','            fimath'};


            if this.RoundingMethodSet
                propList{end+1}='RoundingMethod';
            end
            if this.OverflowActionSet
                propList{end+1}='OverflowAction';
            end
            propList=rightPad(propList);

            cellfun(@(prop)printProperty(prop)...
            ,propList);

            function printProperty(propName)
                propVal=this.(strtrim(propName));
                strPropVal=to_str(propVal);
                if ischar(propVal)
                    strPropVal=['''',strPropVal,''''];
                end
                disp([propName,': ',strPropVal]);

                function res=to_str(val)
                    if iscell(val)
                        strCellVals=cellfun(@(v)to_str(v)...
                        ,val...
                        ,'UniformOutput',false);
                        res=strjoin(strCellVals,' ,');
                    elseif isnumeric(val)
                        if isempty(val)
                            res='[]';
                        else
                            res=num2str(val);
                        end
                    elseif ischar(val)
                        res=val;
                    elseif this.isReallyLogical(val)
                        res=logical2str(val);
                    elseif isnumerictype(val)
                        res=val.tostring;
                    elseif isfimath(val)
                        res=tostring(val);
                    else
                        error('unknown type');
                    end
                end

                function ret=logical2str(val)
                    if islogical(val)
                        if val
                            ret='true';
                        else
                            ret='false';
                        end
                    else
                        error('expecting logical input');
                    end
                end
            end

            function paddedList=rightPad(strList)
                paddedList=cell(1,length(strList));
                maxLength=max(cellfun(@(str)length(str),strList));
                for ii=1:length(strList)
                    str=strList{ii};
                    paddedList{ii}=[repmat(' ',1,maxLength-length(str)),str];
                end
            end
        end
    end
    methods(Access='private')

        function res=isReallyLogical(~,value)
            res=false;
            if iscell(value)
                return;
            end
            res=islogical(value)||all(value==1)||all(value==0);
        end
    end
    methods
        function set.IsInteger(this,value)
            propName='IsInteger';

            this.(propName)=value;
            this.('IsIntegerSet')=true;
        end

        function set.ProposedType(this,value)
            value=convertStringsToChars(value);

            if~isnumerictype(value)&&~isempty(value)
                [s,wlen,flen,err]=coder.internal.Float2FixedConverter.getTypeInfoFromStr(value);
                if err
                    helpLink='<a href="matlab:doc numerictype">numerictype</a>';
                    error(message('Coder:FXPCONV:invalidTypeAnnotation',value,helpLink).getString());
                    return;
                end
                value=numerictype(s,wlen,flen);
            end
            propName='ProposedType';

            this.(propName)=value;


            if~isempty(value)
                this.('ProposedTypeSet')=true;
            end
        end

        function set.RoundingMethod(this,value)
            value=convertStringsToChars(value);

            if~ismember(lower(value),this.LEGAL_ROUNDING_METHODS)
                helpLink='<a href="matlab:doc fimath">fimath</a>';
                error(message('Coder:FXPCONV:invalidRoundingMethodFimath'...
                ,value...
                ,strjoin(coder.FixPtTypeSpec.LEGAL_ROUNDING_METHODS,', ')...
                ,helpLink));
            end

            propName='RoundingMethod';
            this.(propName)=value;
            this.('RoundingMethodSet')=true;
        end

        function set.OverflowAction(this,value)
            value=convertStringsToChars(value);

            if~ismember(lower(value),this.LEGAL_OVERFLOW_ACTIONS)
                helpLink='<a href="matlab:doc fimath">fimath</a>';
                error(message('Coder:FXPCONV:invalidOverflowActionFimath'...
                ,value...
                ,strjoin(coder.FixPtTypeSpec.LEGAL_OVERFLOW_ACTIONS,', ')...
                ,helpLink));
            end

            propName='OverflowAction';
            this.(propName)=value;
            this.('OverflowActionSet')=true;
        end

        function set.fimath(this,value)


            propName='fimath';
            if ischar(value)||isstring(value)
                try
                    [~,fm]=evalc(value);
                catch ex
                    error(message('Coder:FXPCONV:IllegalFiMathStr','<a href="matlab: doc(''fimath'')">fimath</a>'));
                end

                if isstring(value)
                    value=strjoin(strsplit(strrep(fm.tostring,'...','')));
                end
            elseif isfimath(value)


            elseif~isempty(value)


                error(message('Coder:FXPCONV:invalidPropertyType'...
                ,propName...
                ,newline...
                ,class(value)...
                ,class('')));
            end

            if~isempty(value)
                this.(propName)=value;
                this.('FimathSet')=true;
            end
        end
    end
    properties(Hidden)
IsIntegerSet
ProposedTypeSet
RoundingMethodSet
OverflowActionSet
FimathSet
    end
    methods(Static,Hidden)

        function out=getLegalRoudingMethods()
            out=cellfun(@(s)lower(s),set(fimath,'RoundingMethod')'...
            ,'UniformOutput',false);
        end


        function out=getLegalOverflowActions()
            out=cellfun(@(s)lower(s),set(fimath,'OverflowAction')'...
            ,'UniformOutput',false);
        end
    end
end