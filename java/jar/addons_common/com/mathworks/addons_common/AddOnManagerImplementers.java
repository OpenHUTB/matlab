// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   AddOnManagerImplementers.java

package com.mathworks.addons_common;

import com.mathworks.util.ImplementorsCache;
import com.mathworks.util.ImplementorsCacheFactory;
import java.util.*;

// Referenced classes of package com.mathworks.addons_common:
//            AddonManager

public final class AddOnManagerImplementers extends Enum
{

    public static AddOnManagerImplementers[] values()
    {
        return (AddOnManagerImplementers[])$VALUES.clone();
    }

    public static AddOnManagerImplementers valueOf(String s)
    {
        return (AddOnManagerImplementers)Enum.valueOf(com/mathworks/addons_common/AddOnManagerImplementers, s);
    }

    private AddOnManagerImplementers(String s, int i)
    {
        super(s, i);
        addOnManagerImplementersMap = null;
        Collection collection = ImplementorsCacheFactory.getInstance().getImplementors(com/mathworks/addons_common/AddonManager);
        HashMap hashmap = new HashMap();
        AddonManager addonmanager;
        String s1;
        for(Iterator iterator = collection.iterator(); iterator.hasNext(); hashmap.put(s1, addonmanager))
        {
            addonmanager = (AddonManager)iterator.next();
            s1 = addonmanager.getAddonTypeServiced().toLowerCase();
            if(hashmap.containsKey(s1))
                throw new RuntimeException((new StringBuilder()).append("Multiple AddonManager Implementations found for Add-On type : ").append(s1).toString());
        }

        addOnManagerImplementersMap = hashmap;
    }

    public Collection get()
    {
        return addOnManagerImplementersMap.values();
    }

    public AddonManager getImplementerFor(String s)
    {
        if(addOnManagerImplementersMap.containsKey(s.toLowerCase()))
            return (AddonManager)addOnManagerImplementersMap.get(s.toLowerCase());
        else
            throw new UnsupportedOperationException((new StringBuilder()).append("No implementor found for Add-On type: ").append(s).append(".").toString());
    }

    public static final AddOnManagerImplementers INSTANCE;
    private Map addOnManagerImplementersMap;
    private static final AddOnManagerImplementers $VALUES[];

    static 
    {
        INSTANCE = new AddOnManagerImplementers("INSTANCE", 0);
        $VALUES = (new AddOnManagerImplementers[] {
            INSTANCE
        });
    }
}
