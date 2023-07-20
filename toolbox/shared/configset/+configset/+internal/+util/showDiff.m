function showDiff(cs1,cs2,varargin)






    narginchk(2,4);
    switch nargin
    case 2
        try
            name1=cs1.Name;
            name2=cs2.Name;
        catch
            name1='var1';
            name2='var2';
        end
    case 4
        name1=varargin{1};
        name2=varargin{2};
        if~ischar(name1)||~ischar(name2)
            error(message('configset:util:diffInputErr'));
        end
    otherwise
        error(message('configset:util:diffInputErr'));
    end

    [~,v1]=fileparts(tempname);
    [~,v2]=fileparts(tempname);

    assignin('base',v1,cs1);
    assignin('base',v2,cs2);

    eval1=['evalin(''base'', ''',v1,''')'];
    eval2=['evalin(''base'', ''',v2,''')'];
    clean1=['evalin(''base'', ''clear ',v1,''')'];
    clean2=['evalin(''base'', ''clear ',v2,''')'];

    vs1=comparisons.internal.var.makeVariableSource(name1,eval1,clean1);
    vs2=comparisons.internal.var.makeVariableSource(name2,eval2,clean2);

    comparisons.internal.var.startComparison(vs1,vs2);
