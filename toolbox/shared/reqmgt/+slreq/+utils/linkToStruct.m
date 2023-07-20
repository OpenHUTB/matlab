function linkData=linkToStruct(links)










    linkData=rmi.createEmptyReqs(length(links));

    for i=1:length(links)
        link=links(i);

        linkData(i).reqsys=link.destDomain;
        linkData(i).doc=link.destUri;
        linkData(i).id=link.destId;
        linkData(i).description=link.description;

        if strcmp(linkData(i).doc,'UNSPECIFIED_ARTIFACT.txt')



            linkData(i).doc='';
            linkData(i).reqsys='other';

        elseif strcmp(linkData(i).reqsys,'linktype_rmi_simulink')




            [~,linkData(i).doc]=fileparts(linkData(i).doc);
            if any(linkData(i).id=='~')








                [id,sid]=slreq.utils.getShortIdFromLongId(linkData(i).id);
                if~isempty(sid)
                    linkData(i).id=id;
                    linkData(i).doc=[linkData(i).doc,sid];
                    linkData(i).reqsys='linktype_rmi_matlab';
                end
            end
        elseif isempty(link.description)&&strcmp(link.destDomain,'linktype_rmi_slreq')


            linkData(i).description=link.getDefaultLabel();
        end


        linkData(i).keywords=slreq.utils.getKeywords(link);



        isSurrogate=link.getProperty('isSurrogateLink');
        if~isempty(isSurrogate)
            linkData(i).linked=~logical(str2num(isSurrogate));%#ok<ST2NM>
        end
    end
end



