// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   AddonMetadataResolverFactory.java

package com.mathworks.addons_common.util;

import com.mathworks.util.ImplementorsCache;
import com.mathworks.util.ImplementorsCacheFactory;
import java.util.Collection;
import java.util.Iterator;

// Referenced classes of package com.mathworks.addons_common.util:
//            AddonMetadataResolver

public final class AddonMetadataResolverFactory
{

    public static Collection getImplementors()
    {
        return ImplementorsCacheFactory.getInstance().getImplementors(com/mathworks/addons_common/util/AddonMetadataResolver);
    }

    public static AddonMetadataResolver getResolverForAddonType(String s)
        throws IllegalArgumentException
    {
        Collection collection = getImplementors();
        for(Iterator iterator = collection.iterator(); iterator.hasNext();)
        {
            AddonMetadataResolver addonmetadataresolver = (AddonMetadataResolver)iterator.next();
            if(addonmetadataresolver.getAddonTypeServiced().equalsIgnoreCase(s))
                return addonmetadataresolver;
        }

        throw new IllegalArgumentException((new StringBuilder()).append("Unsupported Add-on type [").append(s).append("]!").toString());
    }

    private AddonMetadataResolverFactory()
    {
    }
}
