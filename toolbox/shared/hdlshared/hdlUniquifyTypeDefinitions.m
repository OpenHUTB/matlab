function typedefsOut=hdlUniquifyTypeDefinitions(typedefsIn)






    if~strcmpi(hdlgetparameter('target_language'),'vhdl')||isempty(typedefsIn)
        typedefsOut=typedefsIn;
    else


        typedef_string='  -- Type Definitions\n';
        anyTypes=contains(typedefsIn,typedef_string);
        typedefs=strrep(typedefsIn,typedef_string,'');


        tidx=strfind(typedefs,'  TYPE');
        tidx(end+1)=length(typedefs)+1;
        t={};
        for ii=1:numel(tidx)-1

            t{ii}=typedefs(tidx(ii):tidx(ii+1)-1);%#ok<AGROW>
        end
        typedefs=t;

        typedefs=unique(typedefs,'stable');

        if anyTypes
            typedefsOut=[typedef_string...
            ,typedefs{:}];
        else
            typedefsOut=typedefs{:};
        end
    end

...
...
...
...
...
...
...
...
...
...
...
...

end
