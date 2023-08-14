function makeOutline(cm)




    fName='getOutlineString.m';
    fid=cm.openFile(fName);


    fprintf(fid,'function olstring=getOutlineString(thisComp)\n');
    fprintf(fid,'%% GETOUTLINESTRING Return the string used in the Explorer hierarchy\n');
    fprintf(fid,'%%   OLSTRING=GETOUTLINESTRING(THISCOMP) Returns a single-line string\n');
    fprintf(fid,'%%    which displays important information about the component.  This\n');
    fprintf(fid,'%%    string is displayed in the hierarchy of the Report Explorer.\n');
    fprintf(fid,'%% \n');
    fprintf(fid,'%%   THISCOMP is the component being described.\n');
    fprintf(fid,'%%   OLSTRING is the descriptive string.\n');
    fprintf(fid,'%% \n');
    fprintf(fid,'%%   See also GETNAME\n');
    fprintf(fid,'%% \n\n');

    cm.writeHeader(fid);


    fprintf(fid,'%% *********************************************************************\n');
    fprintf(fid,'%% * By default, GETOUTLINESTRING returns the display name of the      *\n');
    fprintf(fid,'%% * component.                                                        *\n');
    fprintf(fid,'%% *                                                                   *\n');
    fprintf(fid,'%% * The string should be less than 32 characters long.                *\n');
    fprintf(fid,'%% *********************************************************************\n\n');

    fprintf(fid,'olstring = getName(thisComp);\n\n');

    fprintf(fid,'%% *********************************************************************\n');
    fprintf(fid,'%% * The string can be customized to show additional                   *\n');
    fprintf(fid,'%% * information about the component, such as the state of its         *\n');
    fprintf(fid,'%% * properties.                                                       *\n');
    fprintf(fid,'%% *                                                                   *\n');
    fprintf(fid,'%% * The TRUNCATESTRING function converts any data type into a single  *\n');
    fprintf(fid,'%% * line string. The second argument is the return value if the       *\n');
    fprintf(fid,'%% * data is empty.  The third argument is the maximum allowed size    *\n');
    fprintf(fid,'%% * of the resulting string.                                          *\n');
    fprintf(fid,'%% *********************************************************************\n\n');

    fprintf(fid,'cInfo = '''';\n\n');
    thisProp=cm.down;
    while~isempty(thisProp)
        writeOutline(thisProp,fid);
        thisProp=thisProp.right;
    end

    fprintf(fid,'%% *********************************************************************\n');
    fprintf(fid,'%% * The string typically uses a dash ("-") as a separator between the *\n');
    fprintf(fid,'%% * name and additional component information.                        *\n');
    fprintf(fid,'%% *********************************************************************\n\n');
    fprintf(fid,'if ~isempty(cInfo)\n   olstring = [olstring,'' - '',cInfo];\nend\n\n');

    fclose(fid);

    cm.viewFile(fName,1);


    if~isempty(cm.v1OutlinestringFile)&&...
        exist(cm.v1OutlinestringFile,'file')==2
        [~,oFile]=fileparts(cm.v1OutlinestringFile);
        newFile=fullfile(cm.ClassDir,[oFile,'.old']);
        try
            copyfile(cm.v1OutlinestringFile,newFile,'f');
            cm.viewFile([oFile,'.old']);
        catch ME
            cm.ErrorMessage=ME.message;
        end
    end


    function writeOutline(thisProp,fid)


        switch thisProp.DataTypeString
        case 'bool'
            fprintf(fid,'if thisComp.%s  %% %s\n    p%s = ''true'';\nelse\n    p%s = ''false'';\nend\n\n',...
            thisProp.PropertyName,...
            thisProp.Description,...
            thisProp.PropertyName,...
            thisProp.PropertyName);
        case '!ENUMERATION'
            fprintf(fid,'switch thisComp.%s %% %s\n',thisProp.PropertyName,thisProp.Description);
            nameCount=length(thisProp.EnumNames);
            for i=1:length(thisProp.EnumValues)
                if nameCount>=i
                    eName=thisProp.EnumNames{i};
                else
                    eName=thisProp.EnumValues{i};
                end
                fprintf(fid,'    case ''%s'' \n       p%s = ''%s'';\n',...
                thisProp.EnumValues{i},...
                thisProp.PropertyName,...
                strrep(eName,'''',''''''));
            end
            fprintf(fid,'    otherwise\n        p%s = ''<unknown>'';\nend\n\n',...
            thisProp.PropertyName);
        otherwise
            fprintf(fid,'p%s = rptgen.truncateString(thisComp.%s,''<empty>'',16);  %% %s;\n\n',...
            thisProp.PropertyName,thisProp.PropertyName,thisProp.Description);
        end

