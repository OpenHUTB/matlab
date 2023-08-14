function result=getSfunctionExamples(varargin)




    finishup='';
    model='sfundemos';
    rootpath=['sfundemos/C-file',newline,'S-functions/'];
    if(~bdIsLoaded(model))
        load_system(model);
        finishup=onCleanup(@()close_system(model,0));
    end


    temp=find_system('sfundemos/C-file S-functions','MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','SubSystem');
    blockpaths=cell(1,numel(temp)-1);
    j=1;
    for i=2:numel(temp)
        tt=extractAfter(temp{i},rootpath);
        if(contains(tt,'/'))
            blockpaths{j}=tt;
            j=j+1;
        end
    end
    blockpaths=blockpaths(1:j-1);
    temp='';
    displayBlockMap=containers.Map;
    for i=1:numel(blockpaths)
        block=[rootpath,blockpaths{i}];
        pre=extractBefore(blockpaths{i},'/');
        maskObj=Simulink.Mask.get(block);
        display=extractBetween(maskObj.Display,'disp(''',''')');

        if(isempty(display))
            continue;
        else
            display=strrep(display{1},'\n',' ');
        end
        pre=strrep(pre,newline,' ');
        display=[pre,'/',display];
        temp=[temp,{display}];
        displayBlockMap(display)=block;
    end

    if nargin==0
        result=temp;
    else
        result=displayBlockMap(varargin{1});
    end

end
