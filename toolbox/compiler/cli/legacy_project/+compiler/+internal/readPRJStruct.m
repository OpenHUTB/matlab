

function prjStruct=readPRJStruct(prjFileIn)

    [f,name,ext]=fileparts(prjFileIn);
    f=compiler.internal.validate.makePathAbsolute(f);

    if isempty(ext)

        ext='.prj';
    end
    prjFile=fullfile(f,strcat(name,ext));

    prjStruct=readstruct(prjFile,'FileType','xml','DetectTypes',0).configuration;





    projectRoot=fileparts(prjFile);
    if isempty(projectRoot)


        projectRoot=".";
    else
        projectRoot=string(projectRoot);
    end

    prjStruct=resolvePRJPathInStruct(prjStruct);



    function pstruct=resolvePRJPathInStruct(pstruct)
        fields=fieldnames(pstruct);
        for j=1:length(pstruct)
            for i=1:length(fields)
                val=pstruct(j).(fields{i});




                if~isa(pstruct(j).(fields{i}),'missing')
                    if isstruct(val)
                        pstruct(j).(fields{i})=resolvePRJPathInStruct(val);
                    else



                        pstruct(j).(fields{i})=strrep(strrep(strrep(strrep(val,"${PROJECT_ROOT}",projectRoot),"\",filesep),"/",filesep),"\>","/>");





                        if contains(pstruct(j).(fields{i}),'"')
                            if~(all(startsWith(pstruct(j).(fields{i}),'<'))&&all(endsWith(pstruct(j).(fields{i}),'/>')))
                                pstruct(j).(fields{i})=strrep(pstruct(j).(fields{i}),'"','""');
                            end
                        end

                        beforeStr=pstruct(j).(fields{i});
                        if contains(beforeStr,newline)
                            pstruct(j).(fields{i})=strrep(beforeStr,newline,""" + newline + """);
                        end
                    end
                end
            end
        end
    end

end
