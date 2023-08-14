

function Iden=getTypeIdentifier(Type)

    if isa(Type,'embedded.type')
        if isempty(Type.Identifier)
            if(~Type.isPointer)&&(~Type.isMatrix)
                Iden='';
                return
            end
            Iden=getTypeIdentifier(Type.BaseType);
            if Type.isPointer

                if Iden(end)=='*'
                    Iden=[Iden,'*'];
                else
                    Iden=[Iden,'&nbsp;*'];
                end
            end
            if Type.ReadOnly
                if Iden(end)=='*'
                    Iden=[Iden,'const'];
                else
                    Iden=[Iden,'&nbsp;const'];
                end
            end
        else
            Iden=Type.Identifier;
            if Type.Volatile
                Iden=['volatile ',Iden];
            end
            if Type.ReadOnly
                Iden=['const ',Iden];
            end
        end
    else


        Iden='';
    end

end
