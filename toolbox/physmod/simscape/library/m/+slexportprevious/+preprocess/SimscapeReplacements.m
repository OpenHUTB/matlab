function SimscapeReplacements(obj)




    if isR2019aOrEarlier(obj.ver)

        obj.removeBlocksOfType('SimscapeRtp');

    end