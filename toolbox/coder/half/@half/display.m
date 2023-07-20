function display(this)%#ok<DISPLAY>
    name=inputname(1);

    formatSpace=get(0,'FormatSpacing');
    if~isempty(name)
        if(strcmp(formatSpace,'compact'))
            fprintf('%s = \n',name);
        else
            fprintf('\n%s = \n\n',name);
        end
    end

    headerLinkAttributes='style="font-weight:bold"';
    header=getHeaderForNumericClasses(this,headerLinkAttributes);

    if(length(formatSpace)==7)
        fprintf('%s\n',header);
    else
        fprintf('%s\n\n',header);
    end

    disp(this);

end


function out=getHeaderForNumericClasses(inp,headerLinkAttributes)

    if isscalar(inp)
        out=[char(32),char(32),getClassnameString(inp,headerLinkAttributes)];
    else
        ndims=numel(size(inp));
        rows=size(inp,1);
        cols=size(inp,2);
        if isempty(inp)

            if~isreal(inp)

                out=getHeaderForComplexEmptyNumeric(inp,headerLinkAttributes);
            else

                if ndims>2
                    obj=message('MATLAB:services:printmat:EmptyArray',matlab.internal.display.dimensionString(inp),getClassnameString(inp,headerLinkAttributes));
                    out=[char(32),char(32),obj.getString];
                else
                    if rows==1
                        obj=message('MATLAB:services:printmat:EmptyRowVector',matlab.internal.display.dimensionString(inp),getClassnameString(inp,headerLinkAttributes));
                        out=[char(32),char(32),obj.getString];
                    elseif cols==1
                        obj=message('MATLAB:services:printmat:EmptyColumnVector',matlab.internal.display.dimensionString(inp),getClassnameString(inp,headerLinkAttributes));
                        out=[char(32),char(32),obj.getString];
                    else
                        obj=message('MATLAB:services:printmat:EmptyMatrix',matlab.internal.display.dimensionString(inp),getClassnameString(inp,headerLinkAttributes));
                        out=[char(32),char(32),obj.getString];
                    end
                end
            end

        else

            if ndims>2
                obj=message('MATLAB:services:printmat:Array',matlab.internal.display.dimensionString(inp),getClassnameString(inp,headerLinkAttributes));
                out=[char(32),char(32),obj.getString];
            else
                if rows==1
                    obj=message('MATLAB:services:printmat:RowVector',matlab.internal.display.dimensionString(inp),getClassnameString(inp,headerLinkAttributes));
                    out=[char(32),char(32),obj.getString];
                elseif cols==1
                    obj=message('MATLAB:services:printmat:ColumnVector',matlab.internal.display.dimensionString(inp),getClassnameString(inp,headerLinkAttributes));
                    out=[char(32),char(32),obj.getString];
                else
                    obj=message('MATLAB:services:printmat:Matrix',matlab.internal.display.dimensionString(inp),getClassnameString(inp,headerLinkAttributes));
                    out=[char(32),char(32),obj.getString];
                end
            end
        end

    end
end

function out=getHeaderForComplexEmptyNumeric(inp,headerLinkAttributes)
    if matlab.internal.display.isHot
        if isrow(inp)

            obj=message('MATLAB:services:printmat:EmptyComplexRowVector',matlab.internal.display.dimensionString(inp),getClassnameString(inp,headerLinkAttributes));
        elseif iscolumn(inp)

            obj=message('MATLAB:services:printmat:EmptyComplexColumnVector',matlab.internal.display.dimensionString(inp),getClassnameString(inp,headerLinkAttributes));
        elseif numel(size(inp))==2

            obj=message('MATLAB:services:printmat:EmptyComplexMatrix',matlab.internal.display.dimensionString(inp),getClassnameString(inp,headerLinkAttributes));
        else

            obj=message('MATLAB:services:printmat:EmptyComplexArray',matlab.internal.display.dimensionString(inp),getClassnameString(inp,headerLinkAttributes));
        end
    else
        if isrow(inp)

            obj=message('MATLAB:services:printmat:EmptyComplexRowVectorNoHyperlink',matlab.internal.display.dimensionString(inp),getClassnameString(inp,headerLinkAttributes));
        elseif iscolumn(inp)

            obj=message('MATLAB:services:printmat:EmptyComplexColumnVectorNoHyperlink',matlab.internal.display.dimensionString(inp),getClassnameString(inp,headerLinkAttributes));
        elseif numel(size(inp))==2

            obj=message('MATLAB:services:printmat:EmptyComplexMatrixNoHyperlink',matlab.internal.display.dimensionString(inp),getClassnameString(inp,headerLinkAttributes));
        else

            obj=message('MATLAB:services:printmat:EmptyComplexArrayNoHyperlink',matlab.internal.display.dimensionString(inp),getClassnameString(inp,headerLinkAttributes));
        end
    end

    out=[char(32),char(32),obj.getString];
end

function out=getClassnameString(inp,headerLinkAttributes)

    classname=class(inp);

    if matlab.internal.display.isHot
        out=['<a href="matlab:helpPopup ',class(inp),'" ',headerLinkAttributes,'>',classname,'</a>'];
    else
        out=classname;
    end
end
