function displayElements(this)

    len=this.numElements();

    strongBegin='';strongEnd='';
    if matlab.internal.display.isHot()
        strongBegin=getString(message('MATLAB:table:localizedStrings:StrongBegin'));
        strongEnd=getString(message('MATLAB:table:localizedStrings:StrongEnd'));
    end
    varnameFmt=[strongBegin,'%s',strongEnd];


    if len>0&&len<=20
        indexHeader='  ';
        nameHeader=message('SimulationData:Objects:DatasetNameHeading').getString();
        blockPathHeader=message('SimulationData:Objects:DatasetBlockPathHeading').getString();
        valuesHeader=' ';
        propNameHeader=message('SimulationData:Objects:DatasetPropNameHeading').getString();

        printValues=~isa(this.Storage_,...
        'Simulink.SimulationData.Storage.MatFileDatasetStorage');

        maxLen=40;
        indexMaxLen=strlength(indexHeader);
        namesMaxLen=strlength(nameHeader);
        propNamesMaxLen=strlength(propNameHeader);
        blockPathsMaxLen=strlength(blockPathHeader);
        valuesMaxLen=strlength(valuesHeader);
        lBoundary='   ';

        [values,names,propNames,blockPaths]=this.Storage_.utGetMetadataForDisplay();

        propNameExists=~all(cellfun('isempty',propNames));

        namesMaxLen=min(max(namesMaxLen,max(cellfun(@strlength,names))),maxLen);
        propNamesMaxLen=min(max(propNamesMaxLen,max(cellfun(@strlength,propNames))),maxLen);
        blockPathsMaxLen=min(max(blockPathsMaxLen,max(cellfun(@strlength,blockPaths))),maxLen);
        valuesMaxLen=min(max(valuesMaxLen,max(cellfun(@strlength,values))+2),maxLen);


        fprintf('\n%s',lBoundary);
        fprintf(varnameFmt,[locStr(indexHeader,indexMaxLen),' ']);
        if printValues
            fprintf(varnameFmt,[' ',locStr(valuesHeader,valuesMaxLen),'     ']);
        end
        fprintf(varnameFmt,[' ',locStr(nameHeader,namesMaxLen),' ']);
        if propNameExists
            fprintf(varnameFmt,[' ',locStr(propNameHeader,propNamesMaxLen),' ']);
        end
        fprintf(varnameFmt,[' ',locStr(blockPathHeader,blockPathsMaxLen),' ']);
        fprintf('\n');


        fprintf('%s',lBoundary);
        fprintf(varnameFmt,[repmat(' ',1,indexMaxLen),' ']);
        if printValues
            fprintf(varnameFmt,[' ',repmat(' ',1,valuesMaxLen+4),' ']);
        end
        fprintf(varnameFmt,[' ',repmat('_',1,namesMaxLen),' ']);
        if propNameExists
            fprintf(varnameFmt,[' ',repmat('_',1,propNamesMaxLen),' ']);
        end
        fprintf(varnameFmt,[' ',repmat('_',1,blockPathsMaxLen),' ']);
        fprintf('\n');

        if propNameExists
            if printValues
                for idx=1:len
                    fprintf('%s%s  %s  %s  %s  %s\n',lBoundary,...
                    locStr(num2str(idx),indexMaxLen,false),...
                    ['[',locStr(values{idx},valuesMaxLen-2),']    '],...
                    locStr(names{idx},namesMaxLen),...
                    locStr(propNames{idx},propNamesMaxLen),...
                    locStr(blockPaths{idx},blockPathsMaxLen,true,false));
                end
            else
                for idx=1:len
                    fprintf('%s%s  %s  %s  %s\n',lBoundary,...
                    locStr(num2str(idx),indexMaxLen,false),...
                    locStr(names{idx},namesMaxLen),...
                    locStr(propNames{idx},propNamesMaxLen),...
                    locStr(blockPaths{idx},blockPathsMaxLen,true,false));
                end
            end
        else
            if printValues
                for idx=1:len
                    fprintf('%s%s  %s  %s  %s\n',lBoundary,...
                    locStr(num2str(idx),indexMaxLen,false),...
                    ['[',locStr(values{idx},valuesMaxLen-2),']    '],...
                    locStr(names{idx},namesMaxLen),...
                    locStr(blockPaths{idx},blockPathsMaxLen,true,false));
                end
            else
                for idx=1:len
                    fprintf('%s%s  %s  %s\n',lBoundary,...
                    locStr(num2str(idx),indexMaxLen,false),...
                    locStr(names{idx},namesMaxLen),...
                    locStr(blockPaths{idx},blockPathsMaxLen,true,false));
                end
            end
        end

    end

end

function str=locStr(val,maxLen,isLeft,isEllipsisOnRight)
    val=char(val);
    if nargin==3
        isEllipsisOnRight=true;
    end

    if nargin==2
        isLeft=true;
        isEllipsisOnRight=true;
    end

    val=regexprep(val,'\r\n|\n|\r',' ');

    if isempty(val)
        val='''''';
    end

    len=strlength(val);
    if(len>maxLen)&&(maxLen>3)
        if isEllipsisOnRight==true
            str=sprintf('%s...',val(1:maxLen-3));
        else
            str=sprintf('...%s',val(end-(maxLen-1-3):end));
        end
    else
        if isLeft==false
            str=sprintf('%s%s',repmat(' ',1,max(0,maxLen-len)),val(1:min(len,maxLen)));
        else
            str=sprintf('%s%s',val(1:min(len,maxLen)),repmat(' ',1,max(0,maxLen-len)));
        end
    end
end

