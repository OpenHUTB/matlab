function status=register_object_with_sym(fileName,symbolName,object)


















    ecac=rtwprivate('rtwattic','AtticData','ecac');

    status=0;








    try
        if isempty(symbolName)==1
            x=1;
        end





        if isfield(ecac,'file')==0
            ecac.file{1}.name=fileName;
            ecac.file{1}.sinfo{1}.symbolName=symbolName;
            ecac.file{1}.sinfo{1}.objects{1}=object;

        else
            fi=0;


            for j=1:length(ecac.file)
                if strcmp(ecac.file{j}.name,fileName)==1
                    fi=j;
                    break;
                end
            end





            if fi==0
                fi=length(ecac.file)+1;
                ecac.file{fi}.name=fileName;
                ecac.file{fi}.sinfo{1}.symbolName=symbolName;
                ecac.file{fi}.sinfo{1}.objects{1}=object;
            else
                if isfield(ecac.file{fi},'sinfo')==0
                    ecac.file{fi}.sinfo{1}.symbolName=symbolName;
                    ecac.file{fi}.sinfo{1}.objects{1}=object;
                else
                    symbolFound=0;
                    for i=1:length(ecac.file{fi}.sinfo)
                        if strcmp(ecac.file{fi}.sinfo{i}.symbolName,symbolName)==1
                            index=i;
                            symbolFound=1;
                            break;
                        end
                    end
                    if symbolFound==1
                        oindex=length(ecac.file{fi}.sinfo{index}.objects);
                        ecac.file{fi}.sinfo{index}.objects{oindex+1}=object;
                    else
                        index=length(ecac.file{fi}.sinfo);
                        ecac.file{fi}.sinfo{index+1}.symbolName=symbolName;
                        ecac.file{fi}.sinfo{index+1}.objects{1}=object;
                    end
                end
            end
        end
    catch
        status=-1;
    end
    rtwprivate('rtwattic','AtticData','ecac',ecac);
