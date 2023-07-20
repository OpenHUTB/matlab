classdef UsersFilter<handle







    properties(SetAccess=protected)
        InvalidUsers;
    end

    methods
        function this=UsersFilter()
            registerInvalidUsers(this);
        end

        function validUsers=getValidUsers(this,users)


            validUsersIndex=true(numel(users),1);
            for ii=1:numel(users)
                validUsersIndex(ii)=isUserValid(this,users{ii});
            end
            validUsers=users(validUsersIndex);
        end

        function isValid=isUserValid(this,user)


            isValid=true;
            for ii=1:numel(this.InvalidUsers)

                if this.InvalidUsers{ii}(user)
                    isValid=false;
                    break;
                end
            end
        end
    end

    methods(Access=protected)
        registerInvalidUsers(this);
    end
end