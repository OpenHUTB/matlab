function reqStruct=correctDestinationUriAndId(reqStruct)






    for i=1:length(reqStruct)
        reqStruct(i)=validateReqInfo(reqStruct(i));
    end

end


function reqInfo=validateReqInfo(reqInfo)

    switch reqInfo.reqsys

    case 'other'
        reqInfo.doc=strtrim(reqInfo.doc);
        if isempty(reqInfo.doc)



            reqInfo.reqsys='linktype_rmi_text';
            reqInfo.doc='UNSPECIFIED_ARTIFACT.txt';
        elseif~any(reqInfo.doc=='.')

            if~isempty(regexp(reqInfo.doc,'^[0-9a-z]{7,8}$','once'))
                reqInfo.reqsys='doors';
            end
        end

    case 'doors'
        if isempty(reqInfo.doc)


            reqInfo.doc='00000000';
        end

    case 'linktype_rmi_matlab'
        if~contains(reqInfo.doc,'.')

            if rmisl.isSidString(reqInfo.doc)




                [reqInfo.doc,reqInfo.id]=rmisl.correctSimulinkUriAndId(reqInfo.doc,reqInfo.id);
                reqInfo.reqsys='linktype_rmi_simulink';
            else

                reqInfo.doc=[reqInfo.doc,'.m'];
            end
        end

    case 'linktype_rmi_simulink'
        if~contains(reqInfo.doc,'.')

            [reqInfo.doc,reqInfo.id]=rmisl.correctSimulinkUriAndId(reqInfo.doc,reqInfo.id);
        end

    otherwise

    end

end

