function out=comparisons_private(action,varargin)

    switch action
    case 'textdiff'

        out=textdiff(varargin{:});
    case 'bindiff'

        out=comparisons.internal.binary.compare(varargin{:});
    case 'matdiff'

        out=matdiff(varargin{:});
    case 'getMATFileType'

        out=getMATFileType(varargin{:});
    case 'matview'

        matview(varargin{:});
    case 'newcomparison'
        com.mathworks.comparisons.main.ComparisonUtilities.startEmptyComparison;
    case 'comparefiles'
        i_compareFiles(varargin{:});
    case 'comparevars'

        out=comparisons.internal.variablesEqual(varargin{1},varargin{2});
    case 'vardiff'
        out=vardiff(varargin{:});
    case 'linediff'
        [line1,line2]=linediff(varargin{:});
        out={line1,line2};
    case 'diffcode'
        [a,b,c]=diffcode(varargin{:});
        out={a,b,c};


    case 'compare'
        com.mathworks.comparisons.compare.concr.ListComparisonUtilities.compareFiles(varargin{1},varargin{2});
    case 'view'
        com.mathworks.comparisons.compare.concr.ListComparisonUtilities.viewFile(varargin{1},varargin{2},varargin{3});
    case 'skip'
        javaMethod('skipAsync','com.mathworks.comparisons.compare.concr.ListComparisonUtilities',varargin{1});
    case 'cancel'
        javaMethod('cancelAsync','com.mathworks.comparisons.compare.concr.ListComparisonUtilities',varargin{1});


    case 'varcomp'

        i_compareVariables(varargin{:});
    case 'varmerge'
        varmerge(varargin{:});
    case 'varcleanup'
        varcleanup(varargin{1});


    case 'bindiffrefresh'
        c=com.mathworks.comparisons.compare.concr.BinaryComparison.getComparison(varargin{1});
        if~isempty(c)

            c.doRefresh(true)
        else



            c=com.mathworks.comparisons.compare.concr.TextComparison.getComparison(varargin{1});
            if~isempty(c)


                c.doDetailedBinary;
            end
        end



    case 'debug'
        out=cell(1,varargin{2});
        [out{:}]=feval(varargin{1},varargin{3:end});

    otherwise
        comparisons.internal.message('error','comparisons:comparisons:UnknownAction',action);
    end

end

function i_compareFiles(f1,f2,type)
    if nargin<1

        com.mathworks.comparisons.main.ComparisonUtilities.startEmptyComparison;
        return;
    end
    f1=java.io.File(comparisons.internal.resolvePath(f1));
    if nargin<2


        com.mathworks.comparisons.main.ComparisonUtilities.startComparison(f1,[]);
        return;
    end
    f2=java.io.File(comparisons.internal.resolvePath(f2));
    if nargin<3||isempty(type)


        autoselect=true;
    elseif~isempty(type)



        if ischar(type)||(isstring(type)&&isscalar(type))
            type=char(type);


            s1=com.mathworks.comparisons.source.impl.LocalFileSource(f1,f1.getAbsolutePath());
            s2=com.mathworks.comparisons.source.impl.LocalFileSource(f2,f2.getAbsolutePath());
            compatible_types=com.mathworks.comparisons.main.ComparisonTool.getInstance.getCompatibleComparisonTypes(s1,s2,[]);
            for i=0:compatible_types.size-1
                this_type=compatible_types.get(i);
                if strcmpi(this_type.getDataType.getName,type)

                    sel=com.mathworks.comparisons.selection.ComparisonSelection(s1,s2);
                    sel.setComparisonType(this_type);

                    com.mathworks.comparisons.main.ComparisonUtilities.startComparison(sel);
                    return;
                end
            end

            comparisons.internal.message('error','comparisons:comparisons:UnknownComparisonType',type);
        else



            autoselect=logical(type);
        end
    end
    try


        com.mathworks.comparisons.main.ComparisonUtilities.startComparison(f1,f2,autoselect);
    catch E



        if~isempty(strfind(E.message,'NoSuitableComparisonTypeException'))
            msg=char(com.mathworks.comparisons.util.ResourceManager.getString(...
            'exception.nosuitablecomparisontype'));
            msg=strrep(msg,'{0}',char(f1.getAbsolutePath));
            msg=strrep(msg,'{1}',char(f2.getAbsolutePath));
            error('comparisons:comparisons:NoSuitableComparisonType','%s',msg);
        else
            rethrow(E);
        end
    end
end

function i_compareVariables(filename1,filename2,varname)
    refname1=comparisons.internal.loadVariable(filename1,varname,'_left');
    refname2=comparisons.internal.loadVariable(filename2,varname,'_right');
    [~,f1]=fileparts(filename1);
    [~,f2]=fileparts(filename2);
    if~strcmp(f1,f2)
        sourcename1=[f1,'.',varname];
        sourcename2=[f2,'.',varname];
    else
        sourcename1=[f1,'_left.',varname];
        sourcename2=[f2,'_right.',varname];
    end
    vs1=com.mathworks.comparisons.source.impl.VariableSource(sourcename1,...
    ['evalin(''base'',''',refname1,''')'],...
    ['comparisons_private(''varcleanup'',''',refname1,''')']);
    vs2=com.mathworks.comparisons.source.impl.VariableSource(sourcename2,...
    ['evalin(''base'',''',refname2,''')'],...
    ['comparisons_private(''varcleanup'',''',refname2,''')']);
    com.mathworks.comparisons.main.ComparisonUtilities.startComparison(vs1,vs2,true)
end
