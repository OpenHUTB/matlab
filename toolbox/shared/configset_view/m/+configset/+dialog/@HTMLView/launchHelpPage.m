function launchHelpPage(obj,msg)




    try
        if isfield(msg,'shortname')&&~isempty(msg.shortname)

            topic=msg.shortname;
        else

            map=strjoin(msg.map,filesep);
            topic=fullfile(docroot,map);
        end
        tag=msg.tag;
        helpview(topic,tag,'CSHelpWindow');
    catch
        map=fullfile(docroot,'simulink','csh','gui','Simulink.ConfigSet.map');
        tag='defaultListViewTag';
        helpview(map,tag,'CSHelpWindow');
    end
