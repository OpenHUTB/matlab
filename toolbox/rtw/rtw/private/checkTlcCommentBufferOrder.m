
function checkTlcCommentBufferOrder(tlcFolder)



    tlcFiles=dir(tlcFolder);
    for i=1:numel(tlcFiles)
        [~,~,ext]=fileparts(tlcFiles(i).name);
        if strcmp(ext,'.tlc')
            checkTlcBufferPairs(fullfile(tlcFolder,tlcFiles(i).name));
        end
    end
end

function checkTlcBufferPairs(tlcFile)
    content=fileread(tlcFile);
    buffers=regexp(content,'(%(open|close)file)\s+(\w+_(open|body|close)_\w+_\d+_\d+(_\d+)?)','tokens');
    stack=cell(numel(buffers),1);
    j=0;
    for i=1:numel(buffers)
        if strcmp(buffers{i}{1},'%closefile')&&j>0&&strcmp(buffers{i}{2},stack{j}{2})
            stack(j)=[];
            j=j-1;
        else
            j=j+1;
            stack(j)=buffers(i);
        end
    end

    stack=stack(~cellfun('isempty',stack));
    if~isempty(stack)
        errmsg=['Found Mismatched comment TLC buffer pairs in file: ',tlcFile];
        disp('Remaining elements in TLC buffer stack');
        for i=1:numel(stack)
            errmsg=[errmsg,newline,'   ',stack{i}{1},'   ',stack{i}{2}];%#ok<AGROW>
        end
        error(errmsg);
    end
end


