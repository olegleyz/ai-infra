# Internet Exchange Points, Fiber Connectivity, and Data Center Site Selection

## A Primer for Data Center Development

---

## 1. What Is an Internet Exchange Point (IXP)?

An Internet Exchange Point is, at its most physical level, a room (or set of rooms) inside a building containing network switches. These switches allow different internet networks -- your ISP, a cloud provider, a streaming service, a bank -- to plug in and exchange traffic directly with each other.

Think of it like a farmers' market for internet traffic. Without a farmers' market, if you want tomatoes from Farm A and bread from Farm B, both farms have to ship through a distributor (expensive, slow). With a farmers' market, the farms set up stalls in one location and hand goods directly to each other and to customers. An IXP is that marketplace, but for data packets.

**Why it matters for data centers:** A data center next to an IXP is like a warehouse next to a major shipping hub. Your tenants get faster, cheaper, more reliable connectivity to more networks. This is one of the core reasons Ashburn, Virginia became the world's largest data center market -- the early IXPs (MAE-East in the 1990s, then Equinix) seeded an ecosystem that now handles an estimated 70% of the world's internet traffic.

---

## 2. How Internet Traffic Flows

Here is the simplified path of a web request:

```
User's device
    |
    v
Local ISP (e.g., Comcast, AT&T)
    |
    v
[Option A: Transit]  or  [Option B: Peering at an IXP]
    |                           |
    v                           v
Tier 1 backbone network     Direct exchange with
(paid transit -- $$)        destination network (free/cheap)
    |                           |
    v                           v
Destination network         Destination network
    |                           |
    v                           v
Data center / server        Data center / server
```

### Peering vs. Transit

**Transit** is the paid option. A network pays a larger "upstream" network to carry its traffic to the rest of the internet. Think of it as paying for a taxi -- you get where you need to go, but someone else drives and you pay per trip (or per megabit). Transit prices have fallen over time but remain a significant cost, especially in regions like Africa (where transit costs can be 14x the global benchmark).

**Peering** is the handshake option. Two networks agree to exchange traffic directly, typically for free ("settlement-free peering") or for a modest port fee at an IXP. This is like two neighbors agreeing to share a driveway instead of both driving around the block. The savings are enormous: replacing transit with peering can save networks hundreds of thousands to millions of dollars annually.

**The economics in practice:**
- In Europe, where nonprofit IXPs are common, about 60% of traffic is peered, reducing effective network costs dramatically
- Transit pricing has historically declined about 20-30% per year, but peering remains cheaper for high-volume traffic
- The cost difference is so stark that the investment to connect to an IXP typically pays for itself within months

---

## 3. The Global IXP Map

As of 2025, there are over **1,000 active IXPs** globally (up from ~600 in 2020), driven by cloud computing growth, 5G rollout, and the AI boom.

### Major IXPs by Region

**North America (~100 IXPs)**

| IXP / Location | Significance |
|---|---|
| **Equinix Ashburn, VA** | Heart of "Data Center Alley." 150+ data centers in the region. 70% of world internet traffic passes through here. Seeded by MAE-East in the 1990s. |
| **60 Hudson Street, NYC** | A 1930s Art Deco building originally built for Western Union. Converted to a colocation/interconnection hub in the 1980s. One of the world's most important carrier hotels. |
| **One Wilshire, Los Angeles** | Built in 1966 as a law office tower. By the 1990s, became the West Coast's premier interconnection hub and a key link to trans-Pacific submarine cables. |
| **CoreSite, Denver** | Key hub for the Mountain West region, connecting routes between the coasts. |
| **DE-CIX New York** | Peak traffic of ~1.2 Tbps. Growing as a complement to Ashburn. |

**Europe (~200+ IXPs)**

| IXP / Location | Peak Traffic | Notes |
|---|---|---|
| **DE-CIX Frankfurt** | **18.22 Tbps** | World's largest by peak traffic. 1,000+ connected networks. |
| **AMS-IX Amsterdam** | **14.2 Tbps** | One of the oldest and largest. Founded in the 1990s. |
| **LINX London** | ~6+ Tbps | Two locations; key link to transatlantic cables. |

**Asia-Pacific**

| IXP / Location | Notes |
|---|---|
| **JPNAP Tokyo** | Japan's largest. Critical for Asia-Pacific routing. |
| **SGIX Singapore** | Gateway between Asia, Australia, and the Middle East. |
| **HKIX Hong Kong** | Key interconnection point for Greater China traffic. |

**Africa (~50 IXPs)** -- Growing rapidly. IXPs here have an outsized impact because transit costs are extremely high, so local peering provides dramatic savings.

**South America + Oceania (~80 IXPs combined)** -- Brazil's IX.br is notable as one of the world's largest by traffic volume.

---

## 4. Why Proximity to an IXP Matters for a Data Center

### 4a. Latency

Light travels through fiber optic cable at roughly two-thirds the speed of light in a vacuum. In practical terms:

- **Every kilometer of fiber adds approximately 5 microseconds of one-way latency**
- A 100 km fiber run = ~0.5 milliseconds one-way, ~1 ms round-trip
- Every router hop along the way adds additional processing delay

This sounds trivial until you consider real-world requirements:
- **Fraud detection systems** at major banks require sub-3 millisecond round-trip times
- **Voice assistants and recommendation engines** break down with even 5 ms of added delay
- **High-frequency trading** firms pay millions for microseconds of advantage

### 4b. Connectivity Cost

A data center near an IXP can offer tenants direct peering, which dramatically reduces their network costs:
- Transit might cost $0.50-$2.00 per Mbps/month (varies by region and volume)
- Peering at an IXP typically costs only a monthly port fee ($500-$5,000/month for a 10-100 GbE port), regardless of traffic volume
- For a network pushing 100 Gbps, this difference can amount to millions of dollars per year

### 4c. Network Resilience

Proximity to an IXP means proximity to many networks. If one path fails, traffic can reroute through dozens of alternative peers. A data center far from any IXP has fewer failover options and is more dependent on a small number of transit providers.

### 4d. Which Workloads Care Most?

| Workload | Latency Sensitivity | IXP Proximity Importance |
|---|---|---|
| **CDN / content delivery** | **Critical** | **Essential.** CDNs exist to serve content from the nearest point. Being at or near an IXP is the whole business model. |
| **AI inference** | **High** | **Very important.** Real-time responses (chatbots, image recognition, voice) need sub-10ms latency. Must be near population centers and IXPs. |
| **Financial services / trading** | **Extreme** | **Essential.** Microseconds matter. Firms colocate directly at exchange points. |
| **SaaS / enterprise apps** | **Moderate** | **Important.** Users notice lag beyond ~100ms. Proximity helps but isn't make-or-break. |
| **AI training** | **Low** | **Less important.** Training jobs run for hours/days. Latency to end users is irrelevant. What matters is GPU-to-GPU bandwidth *within* the cluster, not external connectivity. These workloads can go to remote sites with cheap power. |
| **Backup / cold storage** | **Minimal** | **Low.** Batch transfers tolerate latency. Cost of storage and power dominate. |

**Key insight:** As AI shifts from training to inference at scale, IXP proximity becomes more important, not less. AI-focused data centers require up to 5x more external connectivity than traditional hyperscale facilities.

---

## 5. Dark Fiber vs. Lit Fiber

### Dark Fiber

Dark fiber is fiber optic cable that has been physically installed in the ground but has no active electronics (lasers, amplifiers, routers) connected to it. It is "dark" because no light is passing through it. You lease the raw glass strands and supply your own equipment.

**Analogy:** Leasing dark fiber is like renting an empty warehouse. You get the building, but you bring your own shelving, forklifts, and staff.

**Advantages:**
- **Total control over capacity.** You choose the electronics, so you can upgrade speeds (from 10G to 400G to 800G) without changing the underlying fiber
- **Privacy and security.** Your traffic is on a dedicated strand -- no shared infrastructure
- **Predictable long-term cost.** Fixed lease payments, typically on 10-20 year terms. No per-Gbps charges
- **Scalability.** As bandwidth needs grow, you upgrade your equipment, not your fiber contract

**Disadvantages:**
- Requires in-house optical networking expertise
- High upfront capital for transponders and amplifiers ($100K-$1M+ depending on distance and capacity)
- You are responsible for monitoring and maintaining the active equipment

### Lit Fiber

Lit fiber is a managed service. The fiber provider installs the cable, lights it with their equipment, and sells you bandwidth as a service (e.g., "100 Gbps between Point A and Point B").

**Analogy:** Lit fiber is like renting a fully furnished office. You walk in and start working, but you can't rearrange the furniture.

**Advantages:**
- Fast deployment, minimal expertise needed
- Lower upfront cost (opex vs. capex)
- Provider handles maintenance and monitoring

**Disadvantages:**
- Less control over capacity and upgrades
- Recurring per-Gbps costs that scale with usage
- Dependent on provider's technology refresh cycle

### Why DC Developers Care About Dark Fiber

For data center site selection, the presence of dark fiber nearby is a strategic asset:
- It signals that major fiber routes already pass through the area
- Tenants (especially hyperscalers and large enterprises) often require dark fiber for their inter-DC connections
- A site with dark fiber access from multiple providers gives tenants options and negotiating leverage
- Conversely, a site with no nearby dark fiber may require a costly new build ($60K-$120K+ per mile) that could take 12-24 months

---

## 6. Fiber Infrastructure: Who Owns It and What Does It Cost?

### Major Fiber Owners (U.S.)

| Company | Network Size | Notes |
|---|---|---|
| **Zayo Group** | **18.7M fiber miles, 146K+ route miles** (pre-Crown Castle). Post-acquisition: **236K+ route miles** | The dominant player. Acquired Crown Castle's fiber business for $4.25 billion in 2025, adding 90,000 route miles. Owned by DigitalBridge. Aggressively building AI-focused routes (Omaha-Dallas, Denver-SLC, etc.) |
| **Lumen Technologies** | ~450,000 route miles globally | Signed $8B+ in private connectivity deals with major tech companies. Strong long-haul backbone. |
| **Crown Castle** | Divesting fiber (sold to Zayo) | Retains ~40,000 cell towers. Previously owned ~32,000 fiber route miles acquired via Lightower ($7.1B in 2017). |
| **Corning** | Fiber manufacturer (not operator) | World's largest maker of optical fiber. Supplies the glass itself. Has sold out its fiber inventory through 2026 due to AI-driven demand. |
| **AT&T, Verizon, Comcast** | Extensive metro/regional fiber | Primarily serve their own customers but also lease capacity. |

### Other Notable Players
- **Uniti Group** -- 140,000+ route miles, focused on fiber leasing
- **Windstream/Kinetic** -- Regional fiber networks
- **FiberLight, FirstLight, Segra** -- Regional/metro fiber providers important in specific markets

### Cost to Build New Fiber

| Component | Cost per Mile |
|---|---|
| **Underground fiber construction (typical)** | $60,000 - $120,000 |
| **Labor** | $120,000 - $160,000 |
| **Total (underground, urban)** | $180,000 - $280,000+ |
| **Aerial (on existing poles)** | $30,000 - $60,000 |
| **Microtrenching (where permitted)** | 30-80% less than traditional boring |

**A real-world example:** Running a 10-mile fiber spur from an existing long-haul route to a new data center campus could cost $1.5M-$3M+ and take 12-24 months including permitting.

### The Scale of What's Needed

The U.S. currently has approximately 95,000 route miles of long-haul fiber. Industry projections indicate this needs to nearly double to **187,000+ route miles by 2029** to meet AI and data center demand. Data centers will require an estimated **214 million additional fiber miles** (strand-miles, not route-miles) by 2029.

---

## 7. Challenges

### 7a. Fiber Scarcity in Secondary and Tertiary Markets

Primary markets (Ashburn, Dallas, Chicago, Phoenix) have dense fiber ecosystems built up over decades. Secondary and tertiary markets often have minimal fiber infrastructure:
- A site in central Iowa may be 30-50 miles from the nearest long-haul fiber route
- Some emerging markets (e.g., parts of the Carolinas, central Pennsylvania) have strong power availability but immature fiber networks
- This creates a chicken-and-egg problem: fiber providers won't build speculatively, but data centers won't commit without fiber

### 7b. Construction Costs and Timelines

- Fiber construction costs have been rising due to labor shortages and material costs
- Global fiber demand surged 75.9% year-over-year in 2025
- The price of standard G.652.D single-mode fiber has risen 30%+ since early 2025
- One major manufacturer has sold its entire fiber inventory through 2026
- A "perfect storm" of AI demand + BEAD broadband funding + limited manufacturing capacity is straining supply

### 7c. Right-of-Way Issues

This is often the single biggest obstacle:
- Building fiber along highways requires permits from state DOTs (often 6-18 months)
- Railroad crossings require separate agreements with each railroad (notoriously slow and expensive)
- Municipal rights-of-way require permits from every jurisdiction the fiber crosses
- Environmental reviews may be required for new routes
- Existing easements may not permit fiber installation
- The Fiber Broadband Association has been lobbying for access to public lands and streamlined permitting

### 7d. Impact on Site Selection

The dynamics of data center site selection have shifted dramatically:
- **Historically:** Fiber proximity was the anchor criterion. You built where the fiber was.
- **2025-2026:** Power availability has overtaken fiber as the primary constraint. Developers are increasingly willing to accept less mature fiber infrastructure in secondary markets if they can secure power quickly.
- **The long-term bet:** Fiber follows compute. If a 200 MW campus is built in a secondary market, fiber providers will eventually extend routes to serve it. But "eventually" can mean 1-3 years, and tenants may not want to wait.

---

## 8. Business Opportunities

The fiber/connectivity layer of the data center ecosystem presents several significant opportunities:

### 8a. Fiber-as-a-Service for New DC Markets

As data centers expand into secondary and tertiary markets (driven by power availability), there is a gap: the fiber isn't there yet. Companies that can finance and build fiber routes to these emerging markets -- essentially "pre-wiring" them for data center development -- can capture long-term lease revenue.

**The math:** A $3M fiber build to a new DC campus, leased to 3-4 tenants on 15-year dark fiber IRUs (Indefeasible Rights of Use), can generate attractive returns, especially if the route serves multiple campuses.

### 8b. "Fiber-Ready" Site Assembly

Acquiring land that sits on or near existing fiber routes, then packaging it with fiber access rights for data center developers. This is increasingly valuable as developers compete for power-and-fiber-adjacent sites.

### 8c. IXP Development in Underserved Markets

Most of the 1,000+ global IXPs are small. Establishing or investing in IXPs in growing secondary markets (e.g., Salt Lake City, Austin-San Antonio, the Carolinas) can create anchor connectivity that attracts data center development. An IXP is relatively cheap to establish compared to a data center -- the value is in the network effect.

### 8d. Fiber Manufacturing and Materials

With fiber demand surging 75.9% YoY and manufacturers sold out through 2026:
- Corning and other manufacturers are expanding capacity
- The data center optic fiber market is projected to grow from $5B (2026) to $9.4B (2033)
- AI data centers require **36x more fiber per rack** than traditional CPU-based facilities

### 8e. Connectivity Brokerage and Consulting

As the market grows more complex (more providers, more routes, more pricing models), there is demand for intermediaries who can:
- Map fiber availability for potential DC sites
- Negotiate dark fiber leases and IRU terms
- Design multi-provider connectivity strategies
- Manage the permitting and construction process for new fiber extensions

### 8f. Joint Fiber-Power Corridors

One emerging model: co-locating fiber and power transmission infrastructure in shared rights-of-way. Since data centers need both, and both face similar permitting challenges, joint development can reduce costs and timelines. The Fiber Broadband Association has specifically called for "joint easements" between power and fiber providers.

---

## Key Takeaways

1. **IXPs are the gravity wells of the internet.** Data centers cluster around them because proximity means lower latency, lower cost, and more resilient connectivity. Ashburn exists because of MAE-East; Amsterdam thrives because of AMS-IX.

2. **Peering beats transit, and IXPs make peering possible.** The cost savings from peering vs. transit are measured in millions of dollars per year for large networks. This is why IXP access is a core selling point for data center operators.

3. **Dark fiber is the preferred medium for serious DC tenants.** It offers control, scalability, and long-term cost predictability. Its presence (or absence) near a site is a major factor in site selection.

4. **Fiber is the new constraint, alongside power.** The industry needs to nearly double U.S. fiber route miles by 2029. Manufacturing is sold out. Prices are rising. This is both a challenge and an opportunity.

5. **The AI shift changes the calculus.** Training workloads care about power, not proximity. Inference workloads care deeply about latency and connectivity. As inference scales up, IXP proximity and fiber density become more important.

6. **Secondary markets are the frontier.** Power scarcity in primary markets is pushing development outward. The biggest opportunity may be in bridging the gap -- bringing fiber infrastructure to power-rich sites before the data centers arrive.

---

## Sources

- [Internet Exchange Point - Wikipedia](https://en.wikipedia.org/wiki/Internet_exchange_point)
- [IXP Tracker - Internet Society Pulse](https://pulse.internetsociety.org/en/ixp-tracker/)
- [Internet Exchange Map - TeleGeography](https://www.internetexchangemap.com/)
- [List of Internet Exchange Points by Size - Wikipedia](https://en.wikipedia.org/wiki/List_of_Internet_exchange_points_by_size)
- [Top 10 Internet Exchange Points Worldwide - DediRock](https://dedirock.com/blog/top-10-internet-exchange-points-worldwide-and-their-importance-for-global-connectivity/)
- [Dateline Ashburn: The Interplay Between IXPs and Data Centers](https://broadbandbreakfast.com/dateline-ashburn-the-interplay-between-ixps-and-data-centers/)
- [AMS-IX: Amsterdam Internet Exchange Point - Stackscale](https://www.stackscale.com/blog/ixp-ams-ix/)
- [IXPs in the US and Internet Peering - Macronet Services](https://macronetservices.com/ixps-us-internet-peering/)
- [Peering vs. Transit Economics - DrPeering](http://drpeering.net/HTML_IPP/chapters/ch05-1-Peering-vs-Transit-Economics/ch05-1-Peering-vs-Transit-Economics.html)
- [Peering Agreements: Revolutionizing DC Connectivity - DataBank](https://www.databank.com/resources/blogs/peering-agreements-revolutionizing-data-center-connectivity-with-direct-network-interlinks/)
- [Internet Interconnection Strategies - US Signal](https://ussignal.com/blog/know-your-options-peering-ip-transit-and-direct-internet-access/)
- [Bandwidth Costs Around the World - Cloudflare](https://blog.cloudflare.com/bandwidth-costs-around-the-world/)
- [Dark Fiber & Data Center Site Selection - LandGate](https://www.landgate.com/news/dark-fiber-data-center-site-selection)
- [Dark Fiber vs Lit Fiber - FiberLight](https://www.fiberlight.com/blog/dark-fiber-vs-lit-fiber-choosing-the-right-fit-for-your-network/)
- [Dark Fiber vs Lit Fiber - CoreSite](https://www.coresite.com/blog/dark-fiber-vs-lit-fiber-networks-pros-and-cons)
- [Fiber & Connectivity Bottlenecks - Global Data Center Hub](https://www.globaldatacenterhub.com/p/fiber-and-connectivity-bottlenecks)
- [Zayo Acquires Crown Castle Fiber Solutions Business](https://www.zayo.com/newsroom/zayo-to-acquire-crown-castles-fiber-solutions-business/)
- [Zayo's Fiber Bet: Scaling for AI Data Centers - Data Center Frontier](https://www.datacenterfrontier.com/network/article/55274499/zayos-fiber-bet-scaling-long-haul-and-metro-networks-for-ai-data-centers)
- [Cost to Run Fiber Per Mile - LatestCost](https://latestcost.com/cost-run-fiber-per-mile-price-range-drivers/)
- [Why Fiber-to-Data Center Projects Cost So Much - Global DC Hub](https://www.globaldatacenterhub.com/p/why-fiber-to-data-center-projects)
- [Study: Data Centers Will Require 214M More Fiber Miles By 2029](https://broadbandbreakfast.com/study-data-centers-will-require-214m-more-fiber-miles-by-2029/)
- ['Perfect Storm' in Fiber Supply - Light Reading](https://www.lightreading.com/fttx/-perfect-storm-in-fiber-supply-threatens-us-broadband-targets)
- [Structural Price Rally in Fiber Optic Cables - OYII](https://www.oyii.net/news/structural-price-rally-in-fiber-optic-cables-ai-powered-demand-supply-constraints-2026-forecast/)
- [Emerging Data Center Markets 2026 - Data Center Knowledge](https://www.datacenterknowledge.com/data-center-site-selection/emerging-data-center-markets-key-locations-to-watch-in-2026)
- [Data Center 2026 Outlook - Morgan Lewis](https://www.morganlewis.com/pubs/2025/12/data-center-2026-outlook-energy-infrastructure-and-connectivity)
- [Latency Kills: Interconnection and AI Infrastructure - DE-CIX](https://www.de-cix.net/en/resources/articles/latency-kills-5-reasons-interconnection-is-the-missing-link-in-ai-infrastructure)
- [Inference Zones: How Data Centers Support Real-Time AI - CoreSite](https://www.coresite.com/blog/inference-zones-how-data-centers-support-real-time-ai)
- [AI and Latency: Why Milliseconds Decide DC Winners - DC Knowledge](https://www.datacenterknowledge.com/infrastructure/ai-and-latency-why-milliseconds-decide-winners-and-losers-in-the-data-center-race)
- [Virginia Data Centers: Ashburn, Loudoun, and Beyond - Dgtl Infra](https://dgtlinfra.com/data-centers-virginia-ashburn-loudoun/)
- [Why Is Ashburn the Data Center Capital of the World?](https://www.datacenters.com/news/why-is-ashburn-the-data-center-capital-of-the-world)
- [60 Hudson Street - Wikipedia](https://en.wikipedia.org/wiki/60_Hudson_Street)
- [One Wilshire - Wikipedia](https://en.wikipedia.org/wiki/One_Wilshire)
- [Fiber Vendors Strategize for AI Demand in 2026 - Fierce Network](https://www.fierce-network.com/broadband/major-fiber-vendors-strategize-huge-demand-ai-2026)
- [Data Center Optic Fibre Market 2025-2033 - Data Insights Market](https://www.datainsightsmarket.com/reports/data-center-optic-fibre-447060)
