


classdef TypeBus<hdlturnkey.data.Type


    properties(Access=protected)


        MemberIDList={};


        MemberTypeMap=[];


        MemberIsRequiredMap=[];


        MemberTypeCanChangeMap=[];
    end


    methods

        function obj=TypeBus()

            obj=obj@hdlturnkey.data.Type();

            obj.MemberIDList={};
            obj.MemberTypeMap=containers.Map();
            obj.MemberIsRequiredMap=containers.Map();
            obj.MemberTypeCanChangeMap=containers.Map();
        end


        function isa=isBusType(~)
            isa=true;
        end
        function slDataType=getSLDataType(~)

            slDataType='bus';
        end


        function addMemberType(obj,memberID,hMemberType,isRequired,typeCanChange)
            if nargin<4
                isRequired=true;
            end
            if nargin<5
                typeCanChange=false;
            end
            obj.MemberTypeMap(memberID)=hMemberType;
            obj.MemberIsRequiredMap(memberID)=isRequired;
            obj.MemberTypeCanChangeMap(memberID)=typeCanChange;
            obj.MemberIDList{end+1}=memberID;
        end
        function list=getMemberIDList(obj)
            list=obj.MemberIDList;
        end
        function hMemberType=getMemberType(obj,memberID)
            hMemberType=obj.MemberTypeMap(memberID);
        end
        function setMemberType(obj,memberID,newMemberType)
            obj.MemberTypeMap(memberID)=newMemberType;
        end
        function isRequired=getMemberIsRequired(obj,memberID)
            isRequired=obj.MemberIsRequiredMap(memberID);
        end
        function typeCanChange=getMemberTypeCanChange(obj,memberID)
            typeCanChange=obj.MemberTypeCanChangeMap(memberID);
        end
        function num=getNumMembers(obj)
            num=obj.MemberTypeMap.length;
        end
        function memberSLDataTypeList=getMemberSLDataTypeList(obj)
            memberIDList=obj.getMemberIDList;
            memberNumber=obj.getNumMembers;
            memberSLDataTypeList=cell(1,memberNumber);
            for ii=1:memberNumber
                memberID=memberIDList{ii};
                hMemberType=obj.getMemberType(memberID);
                memberSLDataTypeList{ii}=hMemberType.getSLDataType;
            end
        end
        function isa=isMemberType(obj,memberID)
            isa=obj.MemberTypeMap.isKey(memberID);
        end
        function hasOptionalPort=hasOptionalMemberPort(obj)
            hasOptionalPort=false;
            memberIDList=obj.getMemberIDList;
            for ii=1:length(memberIDList)
                memberID=memberIDList{ii};
                isRequired=obj.getMemberIsRequired(memberID);
                if~isRequired
                    hasOptionalPort=true;
                    break;
                end
            end
        end


        function initFromPirType(obj,pirBusType)




            busLength=pirBusType.NumberOfMembers;
            busMemberNames=pirBusType.MemberNames;
            busMemberTypes=pirBusType.MemberTypes;

            for ii=1:busLength
                memberID=busMemberNames{ii};
                pirMemberType=busMemberTypes(ii);


                if pirMemberType.isRecordType
                    hMemberType=hdlturnkey.data.TypeBus();
                elseif pirMemberType.isSingleType
                    hMemberType=hdlturnkey.data.TypeSingle();
                elseif pirMemberType.isHalfType
                    hMemberType=hdlturnkey.data.TypeHalf();
                else
                    hMemberType=hdlturnkey.data.TypeFixedPt();
                end


                hMemberType.initFromPirType(pirMemberType);
                obj.addMemberType(memberID,hMemberType);
            end
        end

        function[iseq,msgObj]=isTypeEqual(obj,otherType,thisTypeName,otherTypeName)





            if nargin<3
                megObjTypeName=message('hdlcommon:interface:StrOneType');
                thisTypeName=megObjTypeName.getString;
            end
            if nargin<4
                megObjTypeName=message('hdlcommon:interface:StrTheOtherType');
                otherTypeName=megObjTypeName.getString;
            end

            iseq=false;
            msgObj=[];

            if~otherType.isBusType||isempty(otherType.getMemberIDList)
                msgObj=message('hdlcommon:interface:BusTypeInvalid');
                return;
            end


            memberIDList=obj.getMemberIDList;
            otherIDList=otherType.getMemberIDList;
            if length(memberIDList)~=length(otherIDList)||...
                ~isequal(memberIDList,otherIDList)

                requiredNotMatch=false;
                extraOtherID=false;
                jj=1;
                for ii=1:length(memberIDList)
                    memberID=memberIDList{ii};
                    if jj>length(otherIDList)
                        otherID='';
                    else
                        otherID=otherIDList{jj};
                    end
                    if strcmp(memberID,otherID)
                        jj=jj+1;
                    else
                        isRequired=obj.getMemberIsRequired(memberID);
                        if isRequired
                            requiredNotMatch=true;
                            break;
                        elseif ii==length(memberIDList)&&~isempty(otherID)
                            extraOtherID=true;
                        end
                    end
                end

                if requiredNotMatch||extraOtherID
                    msgAnd=message('hdlcommon:interface:AndStr');
                    msgObj=message('hdlcommon:interface:BusMemberIDMismatch',...
                    thisTypeName,...
                    downstream.tool.getStrFromCell(memberIDList,msgAnd.getString),...
                    otherTypeName,...
                    downstream.tool.getStrFromCell(otherIDList,msgAnd.getString));
                    return;
                end
            end


            for ii=1:length(memberIDList)
                memberID=memberIDList{ii};
                if otherType.isMemberType(memberID)



                    memberType=obj.getMemberType(memberID);
                    memberOtherType=otherType.getMemberType(memberID);
                    if obj.getMemberTypeCanChange(memberID)

                        obj.setMemberType(memberID,memberOtherType);
                        continue;
                    end
                    [member_iseq,member_msgObj]=memberType.isTypeEqual(...
                    memberOtherType,thisTypeName,otherTypeName);
                    if~member_iseq
                        if~isempty(member_msgObj)
                            member_msgStr=member_msgObj.getString;
                        else
                            member_msgStr='';
                        end
                        msgObj=message('hdlcommon:interface:BusMemberTypeMismatch',memberID,member_msgStr);
                        return;
                    end
                end
            end

            iseq=true;
        end

    end

end
