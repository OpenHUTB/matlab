// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   AddonManagerFactory.java

package com.mathworks.addons_common;

import com.mathworks.util.ImplementorsCache;
import com.mathworks.util.ImplementorsCacheFactory;
import java.util.Collection;
import java.util.Iterator;

// Referenced classes of package com.mathworks.addons_common:
//            AddonManager

public final class AddonManagerFactory
{

    private AddonManagerFactory()
    {
    }

    public static Collection getImplementors()
    {
        return ImplementorsCacheFactory.getInstance().getImplementors(com/mathworks/addons_common/AddonManager);
    }

    public static AddonManager getImplementorFor(String s)
        throws UnsupportedOperationException
    {
        Collection collection = getImplementors();
        for(Iterator iterator = collection.iterator(); iterator.hasNext();)
        {
            AddonManager addonmanager = (AddonManager)iterator.next();
            if(addonmanager.getAddonTypeServiced().equalsIgnoreCase(s))
                return addonmanager;
        }

        throw new UnsupportedOperationException((new StringBuilder()).append("No implementor found for Add-On type: ").append(s).append(".").toString());
    }
}
