



function optStruct=extractExtraOptions(optString,optStruct)
    optString=strtrim(optString);

    if~isempty(optString)
        opts=strsplit(optString,{','});

        for ii=1:numel(opts)
            opt=opts{ii};



            equalIdx=strfind(opt,'=');

            if~isempty(equalIdx)
                optName=strtrim(opt(1:equalIdx-1));
                optValue=strtrim(opt(equalIdx+1:end));

                if strcmp(optName,'defaultArraySize')
                    optStruct.defaultArraySize=str2double(optValue);
                else
                    sldv.code.internal.throwError('sldv_sfcn:sldv_sfcn:unknownExtraOption',optName);
                end
            else
                opt=strtrim(opt);

                sldv.code.internal.throwError('sldv_sfcn:sldv_sfcn:unknownExtraOption',opt);
            end
        end
    end
