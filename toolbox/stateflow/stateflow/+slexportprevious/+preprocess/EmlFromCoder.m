function EmlFromCoder(obj)



    if isR2010bOrEarlier(obj.ver)

        machineH=getStateflowMachine(obj);
        if isempty(machineH)
            return;
        end

        emlBlocks=find(machineH,'-isa','Stateflow.EMChart');
        emlBlocks=[emlBlocks;find(machineH,'-isa','Stateflow.EMFunction')];
        for i=1:numel(emlBlocks)
            emlBlocks(i).Script=convertScriptToEml(emlBlocks(i).Script);
        end
    end

    function script=convertScriptToEml(script)


        script=regexprep(script,'(%#codegen)(\s)','%#eml$2');


        mt=mtree(script);
        coderDotMethods={'allowpcode','cstructname','inline','extrinsic','target',...
        'unroll','ceval','nullcopy','opaque','ref','rref','wref','varsize'};
        LP=[];
        for i=1:numel(coderDotMethods)
            B=mtfind(mt,'Kind','DOT','Left.String','coder','Right.String',coderDotMethods{i});
            C=mtpath(B,'Left');
            lp=C.lefttreepos;
            rp=C.righttreepos;
            for j=1:numel(lp);
                script(lp(j):rp(j))='  eml';
            end
            LP=[LP;lp];
        end
        script([LP,LP+1])=[];