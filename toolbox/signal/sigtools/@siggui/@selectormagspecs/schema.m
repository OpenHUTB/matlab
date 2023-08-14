function schema





    pk=findpackage('siggui');


    c=schema.class(pk,'selectormagspecs',pk.findclass('abstract_specsframe'));
    set(c,'Description','Magnitude Specifications');


    if isempty(findtype('string6'))
        schema.UserType('string6','string vector',@check_string);
    end


    p=schema.prop(c,'AllOptions','string6');
    set(p,'SetFunction',@setalloptions,...
    'FactoryValue',{'Normal','Nonnegative','Minimum-phase'});


    p=schema.prop(c,'Comment','string vector');



    function check_string(value)

        if length(value)>6
            error(message('signal:siggui:selectormagspecs:schema:InternalError'))
        end


        function alloptions=setalloptions(this,alloptions)

            delete(findprop(this,'currentSelection'));



            flag=0;
            indx=-1;
            while~flag
                indx=indx+1;
                PropName=['SMSSelection',num2str(indx)];
                CT=findtype(PropName);
                if isempty(CT)
                    flag=1;
                    s=schema.EnumType(PropName,alloptions);
                else
                    List=get(CT,'Strings');
                    flag=local_isequal(List,alloptions);
                end
            end

            p=schema.prop(this,'currentSelection',PropName);


            function f=local_isequal(List,currOptList)

                if~(length(List)==length(currOptList))
                    f=false;
                else
                    f=all(strcmp(List,currOptList));
                end


