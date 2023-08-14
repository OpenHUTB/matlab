function s=toString(v,varargin)








    n=numel(varargin);
    for i=1:n
        if isstring(varargin{i})
            varargin{i}=char(varargin{i});
        end
    end


    [charLimit,cr,formatSpec]=locParseInputArgs(varargin{:});

    if ischar(v)
        s=locRenderChar(v,charLimit,cr);

    elseif isstring(v)
        if isscalar(v)
            s=locRenderChar(char(v),charLimit,cr);
        else
            s=locRenderStringArray(v,charLimit,cr);
        end

    elseif isobject(v)



        if isenum(v)


            s=locRenderEnum(v,charLimit,cr,formatSpec);
        elseif isnumeric(v)||islogical(v)

            s=locRenderNumeric(v,charLimit,cr,formatSpec);
        else
            s=locRenderMCOSObject(v);
        end

    elseif isnumeric(v)||islogical(v)
        s=locRenderNumeric(v,charLimit,cr,formatSpec);

    elseif iscellstr(v)
        s=locRenderCellStr(v,charLimit,cr);

    elseif iscell(v)
        s=locRenderCell(v,charLimit,cr);

    elseif isstruct(v)
        s=locRenderStruct(v,charLimit,cr);

    elseif isa(v,'DAStudio.Object')||isa(v,'Simulink.DABaseObject')
        s=locRenderDAObject(v,charLimit,cr);

    else
        s=locRenderViaDISP(v,charLimit,cr);
    end


    s=string(s);


    function sizeString=locRenderSizeString(sizeVector,isMinimize)



        if((nargin>1)&&isMinimize...
            &&(length(sizeVector)<3)...
            &&(max(sizeVector)==1))

            sizeString='';
        else

            sizeString=sprintf('%ix',sizeVector);

            sizeString(end)=' ';
        end


        function string=locRenderStruct(value,charLimit,cr)

            string=[];

            if~isempty(fieldnames(value))
                siz=size(value);
                nDims=length(siz);

                if((nDims>2)||(max(siz)>1))

                    compactStruct=1;

                else



                    string=locRenderViaDISP(value,inf,cr);
                    compactStruct=(length(string)>charLimit);
                end

                if compactStruct




                    sizStr=locRenderSizeString(siz,true);


                    string=sprintf('[%s%s w/ fields: %%s]',sizStr,'struct');

                    if(length(string)>charLimit+8)


                        string=sprintf('[%s%s]',sizStr,'struct');

                    else

                        f=mlreportgen.utils.makeSingleLineText(fieldnames(value),', ');

                        if(length(f)>charLimit-length(string))
                            f=f(1:charLimit-length(string));
                            if(length(f)<3)


                                f='...';
                            else


                                f(end-2:end)='...';
                            end
                        end


                        string=sprintf(string,f);
                    end
                end


                string=strrep(string,newline,cr);
            end


            function str=locRenderEnum(value,charLimit,cr,formatSpec)

                if isnumeric(value)||islogical(value)
                    underlyingValue=locRenderNumeric(value,charLimit,cr,formatSpec);
                    varStringValue=string(value);

                    if islogical(value)


















                        if value
                            underlyingValue=getString(message("mlreportgen:utils:toString:logicalTrue"));
                        else
                            underlyingValue=getString(message("mlreportgen:utils:toString:logicalFalse"));
                        end
                    end
                    str=strcat(varStringValue," ","(",underlyingValue,")");

                else
                    str=string(value);
                end


                function string=locRenderCell(value,charLimit,cr)

                    siz=size(value);
                    nDims=length(siz);

                    isCollapse=false;
                    if isempty(value)

                        string='{}';

                    elseif(nDims<3)








                        string='{';
                        for i=1:siz(1)
                            j=1;
                            sLength=length(string);
                            while(j<=siz(2))&&~isCollapse


                                pctCharLimit=(charLimit-sLength)/((i-1)*siz(2)+j);

                                dispValue=mlreportgen.utils.toString(value{i,j},pctCharLimit,' ');
                                if isempty(dispValue)
                                    dispValue='';
                                else
                                    dispValue=char(dispValue);
                                end

                                string=[string,' ',dispValue,' ,'];%#ok

                                j=j+1;
                                sLength=length(string);
                                isCollapse=~(sLength<=charLimit);
                            end
                            string(end)=';';


                            string=[string,cr];%#ok
                        end
                        string(end-1)='}';


                        string(end)=[];
                        string(end-1)=[];
                        string(2)=[];


                        string=strrep(string," ,",",");
                        string=strrep(string," ;",";");

                    else







                        isCollapse=true;
                    end

                    if isCollapse
                        string=sprintf('[%s cell]',locRenderSizeString(siz));
                    end


                    function string=locRenderStringArray(value,charLimit,cr)

                        value=num2cell(value);

                        siz=size(value);
                        nDims=length(siz);

                        isCollapse=false;
                        if isempty(value)

                            string='[]';

                        elseif(nDims<3)




                            string='[';
                            for i=1:siz(1)
                                j=1;
                                sLength=length(string);
                                while(j<=siz(2))&&~isCollapse


                                    pctCharLimit=(charLimit-sLength)/((i-1)*siz(2)+j);

                                    if i>1
                                        leftQuote=' "';
                                    else
                                        leftQuote='"';
                                    end

                                    string=[string...
                                    ,leftQuote...
                                    ,char(mlreportgen.utils.toString(value{i,j},pctCharLimit))...
                                    ,'",'];%#ok

                                    j=j+1;
                                    sLength=length(string);
                                    isCollapse=~(sLength<=charLimit);
                                end
                                string(end)=';';


                                string=[string,cr];%#ok
                            end
                            string(end-1)=']';
                            string(end)=[];

                        else



                            isCollapse=true;
                        end

                        if isCollapse
                            string=sprintf('[%s string array]',locRenderSizeString(siz));
                        end


                        function string=locRenderViaDISP(value,charLimit,cr)


                            try
                                string=evalc('disp(value)');


                                string=regexprep(string,'^\n+|\n+$','');


                                string=strrep(string,newline,cr);

                                forceCollapse=false;
                            catch ex %#ok<NASGU>
                                forceCollapse=true;
                            end

                            if(forceCollapse||(length(string)>charLimit))
                                siz=size(value);
                                string=sprintf('[%s%s]',locRenderSizeString(siz),class(value));
                            end



                            function string=locRenderNumeric(value,charLimit,cr,formatSpec)

                                siz=size(value);
                                nElem=prod(siz);
                                nDims=length(siz);


                                dispFormat=get(0,'Format');
                                switch dispFormat(1)
                                case 'b'

                                    typNumStrLen=4;
                                    precision=2;
                                case 'l'

                                    typNumStrLen=17;
                                    precision=7;

                                otherwise

                                    typNumStrLen=6;
                                    precision=[];
                                end

                                if((nDims>2)||(nElem*typNumStrLen>charLimit))



                                    string=sprintf('<%s%s>',locRenderSizeString(siz),class(value));

                                elseif(nElem==1)
                                    if~isempty(formatSpec)
                                        try
                                            string=num2str(value,formatSpec);

                                            string=strrep(string,newline,cr);

                                            if(length(string)>charLimit)
                                                siz=size(value);
                                                string=sprintf('[%s%s]',locRenderSizeString(siz),class(value));
                                            end
                                        catch me
                                            warning(message("mlreportgen:report:warning:invalidNumericFormat",[me.message]));
                                            string=strtrim(locRenderViaDISP(value,charLimit,cr));
                                        end
                                    elseif isobject(value)


                                        if isinteger(value)||isempty(precision)
                                            string=num2str(double(full(value)));
                                        else
                                            string=num2str(double(full(value)),precision);
                                        end
                                    else





                                        string=strtrim(locRenderViaDISP(value,charLimit,cr));
                                    end

                                elseif(nElem==0)

                                    string='[]';

                                else











                                    if~isempty(formatSpec)


                                        if~isnumeric(formatSpec)&&~endsWith(formatSpec," ")
                                            spec=strcat(formatSpec," ");
                                        else
                                            spec=formatSpec;
                                        end

                                        try
                                            string=num2str(double(full(value)),spec);
                                        catch me
                                            warning(message("mlreportgen:report:warning:invalidNumericFormat",[me.message]));
                                            string=num2str(double(full(value)));
                                        end
                                    elseif isinteger(value)||isempty(precision)


                                        string=num2str(double(full(value)));
                                    else
                                        string=num2str(double(full(value)),precision);
                                    end
                                    brackets='[]';


                                    blankColumn=blanks(size(string,1))';


                                    semicolonColumn=';';
                                    semicolonColumn=semicolonColumn(ones(size(string,1),1));


                                    crColumn=cr(ones(size(string,1),1));


                                    string=[blankColumn,string,blankColumn,semicolonColumn,crColumn];
                                    string(1,1)=brackets(1);
                                    string(end,end-1)=brackets(2);
                                    string(end,end)=' ';


                                    string=string';
                                    string=string(:)';


                                    string(string==0)=' ';


                                    string(end)=[];
                                    string(end-1)=[];


                                    string=regexprep(string," +"," ");
                                    string=strrep(string," ;",";");

                                end


                                function string=locRenderChar(value,charLimit,cr)

                                    siz=size(value);
                                    nElem=prod(siz);
                                    nDims=length(siz);

                                    if(nDims>2)||(nElem>charLimit)



                                        string=sprintf('[%schar]',locRenderSizeString(siz));

                                    elseif(nDims>1)


                                        string=mlreportgen.utils.makeSingleLineText(value,cr);

                                    else


                                        string=v;
                                    end


                                    function string=locRenderCellStr(value,charLimit,cr,objType)

                                        siz=size(value);
                                        nDims=length(siz);

                                        if(nargin<4)
                                            objType='cellstr';
                                        end

                                        if(nDims<3)&&(min(siz)==1)





                                            string=mlreportgen.utils.makeSingleLineText(value,cr);
                                            if(length(string)>charLimit)
                                                string=sprintf('[%s %s]',locRenderSizeString(siz),objType);
                                            end
                                        else







                                            string=locRenderCell(value,charLimit,cr);

                                        end


                                        function string=locRenderDAObject(value,charLimit,cr)




                                            value=value(:);
                                            vLen=length(value);
                                            cellStr=cell(1,vLen);
                                            for i=1:vLen
                                                cellStr{i}=getDisplayLabel(value(i));
                                            end
                                            string=locRenderCellStr(cellStr,charLimit,cr,'DAStudio.Object');


                                            function string=locRenderMCOSObject(value)
                                                sz=size(value);
                                                szStr=locRenderSizeString(sz,true);
                                                string=sprintf("<%s%s>",szStr,class(value));


                                                function[charLimit,cr,formatSpec]=locParseInputArgs(varargin)


                                                    charLimit=inf;
                                                    cr=newline;
                                                    formatSpec=[];

                                                    if(nargin==3)
                                                        formatSpec=varargin{3};
                                                        if~isempty(varargin{1})
                                                            charLimit=varargin{1};
                                                        end
                                                        if~isempty(varargin{2})
                                                            cr=varargin{2};
                                                        end

                                                    elseif(nargin==2)
                                                        charLimit=floor(varargin{1});
                                                        cr=varargin{2};

                                                    elseif(nargin==1)
                                                        charLimit=floor(varargin{1});

                                                    end

                                                    if(charLimit<=0)
                                                        charLimit=inf;
                                                    end
