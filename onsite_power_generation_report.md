# On-Site & Behind-the-Meter Power Generation for AI Data Centers

*Comprehensive Research Report | March 2026*

---

## Table of Contents

1. [The Core Question: Why Not Just Build Your Own Power Plant?](#1-the-core-question)
2. [When It IS Being Done: The Full Menu of Options](#2-the-full-menu)
3. [Deep Dive: Each Technology Option](#3-deep-dives)
4. [Comparison Table: All Options at a Glance](#4-comparison-table)
5. [The Economics: Why a 100MW Data Center Doesn't Just Build a 100MW Gas Plant](#5-the-economics)
6. [Regulatory Barriers](#6-regulatory-barriers)
7. [Recent News and Trends (2025-2026)](#7-recent-news)
8. [Sources](#8-sources)

---

## 1. The Core Question: Why Don't Data Centers Just Build Their Own Power Plants? {#1-the-core-question}

It sounds like a simple idea: if your AI data center needs 100 megawatts, just build a 100-megawatt power plant next door. You control your own destiny, you skip the multi-year utility interconnection queue, and you never have to negotiate with a utility again.

The reason most data centers haven't done this -- until very recently -- is a cocktail of five interlocking problems. Understanding them explains why the landscape is changing so fast right now.

### Problem 1: Running a Power Plant Is a Different Business

Data center companies are tech companies. Running a power plant requires a completely different set of skills: fuel procurement, emissions monitoring, maintenance crews who understand turbine bearings, compliance with Clean Air Act permits, and 24/7 operations staff. It is more financially and administratively burdensome than simply buying electricity from the local utility. Most data center operators historically concluded it wasn't worth the headache.

### Problem 2: Regulation Was Designed for a Different World

The U.S. electricity system was built on a model where utilities generate power, transmit it, and deliver it to customers. If you generate your own power and serve it to others -- or even to yourself on a large scale -- you may trip over utility franchise laws, Federal Power Act jurisdiction, FERC rate regulation, and state public utility commission rules. Until recently, becoming your own power provider meant potentially becoming a regulated utility yourself, with all the obligations that entails.

### Problem 3: Interconnection Queues (The "Wait in Line" Problem)

Even if you build your own generation, you likely still need a grid connection for backup, startup power, and reliability. Getting that grid connection can take 5-7 years in the PJM region (the grid operator covering the data center-heavy mid-Atlantic). You can build a data center in 18-24 months, but the power infrastructure to connect it takes far longer.

### Problem 4: Scale Mismatch (This One Is Complicated)

A 100MW gas turbine is absolutely a thing that exists and can be built. The scale mismatch isn't about the generation equipment -- it's about the supporting infrastructure. A power plant needs gas pipeline connections, water for cooling, emissions permits, transmission interconnection, and staff. All of this has minimum fixed costs that don't scale down linearly. A utility can spread those costs across millions of customers; a single data center absorbs them all alone. More on the economics below.

### Problem 5: Speed vs. Doing It Right

The AI boom created urgency that the traditional utility model cannot accommodate. Grid interconnection takes 5+ years. Building a permitted, fully compliant gas plant takes 3-4 years. But AI companies need power in 12-18 months. This tension is the single biggest driver of the current gold rush in behind-the-meter generation -- and also the source of most of the controversy (see: xAI in Memphis).

### What Changed?

Starting around 2024, these barriers began crumbling under the sheer weight of AI power demand. Grid queues grew so long that they became an existential threat to AI business timelines. In response:

- Companies started deploying gas turbines first and asking permission later (xAI)
- FERC began rewriting the rules for colocation at power plants (December 2025)
- The Trump administration issued executive orders to fast-track data center permitting (July 2025)
- Senator Cotton proposed the DATA Act (2026), which would create a new category of "consumer-regulated electric utilities" exempt from Federal Power Act requirements -- as long as they stay completely off-grid
- Tech companies signed the "Ratepayer Protection Pledge" (March 2026), committing to build, bring, or buy their own generation rather than burden existing ratepayers

The result: in November 2024, data center leaders expected approximately 30% of all data center sites to use on-site power as a primary energy source by 2030 -- 2.3x more than they'd predicted just seven months earlier. By 2026, 38% of data centers expect to use some on-site generation for primary power, with 27% expecting to be *fully* powered by on-site generation by 2030, a 27x increase from just 1% the prior year.

---

## 2. When It IS Being Done: The Full Menu of Options {#2-the-full-menu}

Here is every significant approach currently being pursued or seriously explored for on-site / behind-the-meter / dedicated data center power generation. They range from "deployable this quarter" to "won't be ready until the 2030s."

| Approach | Maturity | Timeline | Who's Doing It |
|----------|----------|----------|----------------|
| Simple-cycle gas turbines (on-site) | Deployed now | 6-18 months | xAI, Meta, OpenAI/Crusoe |
| Combined-cycle gas plants (on-site) | Under construction | 2-4 years | Meta/Entergy, various |
| Fuel cells (natural gas) | Deployed now | 3-6 months | Bloom Energy + Oracle, CoreSite |
| Behind-the-meter reciprocating engines | Deployed now | 6-12 months | INNIO/VoltaGrid, various |
| Co-location at existing power plants | Active / evolving | 1-3 years | Amazon/Talen (Susquehanna) |
| Direct PPA from adjacent generation | Active | 1-3 years | Microsoft/Constellation (TMI) |
| Existing nuclear restart | Under development | 2-4 years | Constellation (TMI for Microsoft) |
| Solar + battery (on-site) | Deployed now | 6-18 months | Aligned Data Centers, various |
| Small Modular Reactors (SMRs) | Pre-commercial | 5-10+ years | Amazon, Google/Kairos, Meta |
| Enhanced geothermal | Early commercial | 2-5 years | Google/Fervo Energy |
| Diesel/HVO backup as bridge | Common (controversial) | Immediate | Widespread, especially Virginia |

---

## 3. Deep Dive: Each Technology Option {#3-deep-dives}

### 3A. Natural Gas Turbines -- Simple Cycle (On-Site)

**The story:** This is the "move fast and break things" option of the power generation world. Simple-cycle gas turbines are essentially jet engines bolted to generators. They can be shipped to a site, connected to a gas line, and firing within months. They're not as efficient as combined-cycle plants (which capture waste heat), but they're fast.

**Who's doing it:**

- **xAI (Memphis):** Deployed up to 35 gas turbines at its Memphis Colossus data center, generating approximately 422MW. This became the poster child for both the promise and the controversy of on-site generation. Residents complained about noise and air quality. Environmental groups alleged the turbines operated without proper permits, emitting 1,200-2,000 tons of smog-forming NOx per year -- making it likely the largest industrial NOx emitter in Memphis. xAI subsequently began removing half the turbines as grid power became available.

- **OpenAI/Crusoe (Stargate):** Ordered 29 gas turbines capable of producing 34MW each for the Stargate data center in Abilene, Texas.

- **Meta (Hyperion, Louisiana):** Using gas turbines alongside combined-cycle plans for its multi-gigawatt AI campus in Richland Parish.

**Pros:** Fast deployment (6-18 months). Proven technology. Available in a wide range of sizes from 25MW to 300MW+. Can be deployed as "temporary" bridge power while waiting for grid connection.

**Cons:** Lower efficiency (~33-40% vs. ~55-60% for combined cycle). Higher emissions per MWh. Air quality permit challenges. Community opposition. Fuel cost exposure. Noise.

**Capital cost:** $325-1,500/kW depending on unit size (larger = cheaper per kW).

### 3B. Natural Gas -- Combined Cycle (On-Site or Adjacent)

**The story:** Combined-cycle plants capture the waste heat from gas turbines to drive a steam turbine, boosting efficiency from ~35% to ~55-60%. They're the gold standard for new gas generation. But they're bigger, more complex, and take longer to build.

**Who's doing it:**

- **Meta/Entergy (Hyperion, Louisiana):** Entergy is building three new combined-cycle gas plants with a combined capacity of 2.3GW to power Meta's Hyperion campus, at a cost of roughly $4 billion. First power expected around 2028-2030.

**Pros:** High efficiency (~55-60%). Lower emissions per MWh than simple cycle. Proven, reliable technology. Lower fuel costs per MWh due to efficiency.

**Cons:** 3-4 year construction timeline. High capital cost ($670-2,500/kW depending on scale). Requires water for cooling. Major air quality permits required. Still fossil fuel = carbon liability.

**Capital cost:** $670/kW at 1,680MW scale up to $1,579/kW at 34MW scale. A 100MW plant would likely cost $1,000-1,400/kW, or roughly $100-140 million.

### 3C. Fuel Cells (Natural Gas / Hydrogen)

**The story:** Fuel cells convert natural gas (or hydrogen) directly into electricity through an electrochemical reaction, without combustion. This means dramatically lower emissions -- no NOx, no SOx, minimal particulates. Bloom Energy is the dominant player here, and their pitch to data centers is compelling: they can deliver 50MW in 90 days and 100MW in 120 days.

**Who's doing it:**

- **Bloom Energy + Oracle:** Announced a collaboration to deliver on-site power for Oracle Cloud Infrastructure data centers, with the ability to power an entire data center within 90 days.
- **CoreSite:** Deployed fuel cells for on-site generation at data center facilities.
- **Bloom Energy** is on track to double annual production capacity to 2GW by end of 2026, and already supplies over 400MW of power to data centers worldwide.

**Pros:** Fastest deployment of any baseload technology (90-120 days for 50-100MW). Very low emissions (no combustion). Quiet operation. Modular and scalable. High reliability (99.9% to 99.999% availability). No water required for cooling. Can run on hydrogen when available.

**Cons:** Higher capital cost (~$7,000/kW installed, roughly 2x solar). Still requires natural gas (unless hydrogen). Higher LCOE than grid power in most markets. Efficiency of ~54% on gas (though up to 90% with combined heat and power). Limited to ~100MW increments currently.

**Goldman Sachs estimates** that 6-15% of incremental data center power demand, or 25-50% of behind-the-meter supply, could be fuel cells by 2030, corresponding to 8-20GW of capacity.

### 3D. Behind-the-Meter Reciprocating Gas Engines

**The story:** These are large natural gas engines (like scaled-up versions of your car engine) that are cheaper per MW than turbines at smaller scales and can be deployed modularly. They're particularly good at following variable loads.

**Who's doing it:**

- **INNIO Group / VoltaGrid:** Announced the largest order in INNIO's history -- a 2.3GW power infrastructure project with VoltaGrid featuring 92 power packs, each delivering 25MW, engineered specifically for data center deployment.

**Pros:** Modular deployment. Good efficiency at partial loads. Faster to deploy than combined cycle. Available in smaller increments.

**Cons:** Still fossil fuel. Air quality permits required. Maintenance-intensive. Lower efficiency than combined cycle at full load.

### 3E. Co-Location with Existing Power Plants

**The story:** Instead of building new generation, why not park your data center next to a power plant that already exists? This is the "co-location" model -- the data center physically connects to the power plant behind the meter, potentially bypassing the transmission grid entirely.

This was the original vision for the Amazon/Talen deal at the Susquehanna nuclear plant in Pennsylvania. The idea was elegant: take power directly from a 2.5GW nuclear plant without touching the grid. But it sparked a fierce regulatory battle.

**Who's doing it:**

- **Amazon / Talen Energy (Susquehanna):** Originally structured as behind-the-meter co-location at the 2.5GW Susquehanna nuclear plant. FERC denied this arrangement twice (the last denial in April 2025), citing concerns about grid reliability and cost-shifting to other ratepayers. Talen then restructured into a 17-year, $18 billion PPA flowing through the grid (front-of-the-meter), supplying up to 1,920MW to Amazon.

**The regulatory catch:** FERC's concern is that when a big data center siphons power from an existing plant behind the meter, the grid loses that generation capacity, potentially raising prices and reducing reliability for everyone else. This is why FERC ordered PJM to develop new co-location rules in December 2025.

**Pros:** Leverages existing generation (no new plant construction). Can be fast if plant has spare capacity. No fuel procurement needed (for the data center operator). Access to carbon-free power (if nuclear).

**Cons:** Regulatory uncertainty (FERC has been hostile to behind-the-meter models). Potential grid reliability impacts. Limited to locations adjacent to existing plants. May face opposition from utilities who lose a customer.

### 3F. Direct Power Purchase from Adjacent/Dedicated Generation

**The story:** This is a variation on co-location where the data center buys power from a dedicated or restarted plant through a long-term Power Purchase Agreement (PPA), but the power flows through the grid rather than behind the meter.

**Who's doing it:**

- **Microsoft / Constellation (Three Mile Island):** The landmark deal. Constellation is investing $1.6 billion to restart Three Mile Island Unit 1 (an 837MW nuclear reactor shut down in 2019). Microsoft has a 20-year PPA for 100% of the output. The DOE closed a $1 billion loan for Constellation in December 2025. Target restart: 2028. Notably, there are no plans to co-locate a Microsoft data center at the plant -- the power will match Microsoft's consumption across data centers in Pennsylvania, Chicago, Virginia, and Ohio through the grid.

**Pros:** Access to large-scale, carbon-free generation. Avoids the co-location regulatory fight. Long-term price certainty. No need to operate a power plant yourself.

**Cons:** Power still flows through the grid (so you need grid capacity). Subject to transmission constraints and costs. Very large financial commitment ($16 billion over 20 years). Limited opportunities (not many 800MW nuclear plants sitting idle).

### 3G. Small Modular Reactors (SMRs)

**The story:** SMRs are the "holy grail" -- modular nuclear reactors that could theoretically be factory-built, shipped to a site, and provide decades of carbon-free baseload power. The problem? They don't exist commercially yet.

**Who's pursuing this:**

- **Amazon:** Unveiled plans for 12 SMRs in Washington state producing up to 960MW. First phase: four SMRs producing 320MW. Construction expected to start by end of this decade, operations targeted for the 2030s.

- **Google / Kairos Power:** Signed the first US corporate SMR fleet deal for 500MW, targeting 2030+.

- **Meta:** Issued an RFP for 1-4GW of new nuclear generation.

- **NuScale:** Had the only NRC-certified SMR design in the US, but their flagship project (the Carbon Free Power Project with UAMPS) was cancelled in November 2023 after costs ballooned from $5.3B to $9.3B and the estimated electricity price reached $89/MWh (up from $58/MWh). NuScale is still pursuing other projects.

**The cost reality is sobering.** First-of-a-kind SMRs face capital costs of $3,000-6,000/kW, and NuScale's cancelled project reached an unsubsidized estimate of $20,139/kW. Manufacturers project costs will fall through series production, but nobody has demonstrated this yet.

**Pros:** Carbon-free. Extremely reliable (nuclear plants run at 90%+ capacity factor). Long operational life (40-60+ years). Small footprint relative to output. Could be transformational if costs come down.

**Cons:** Not commercially available yet (earliest: early 2030s). Enormous cost uncertainty. Nuclear regulatory approvals take years. Public perception challenges. Spent fuel management. First-of-a-kind cost risk is massive.

### 3H. Solar + Battery Storage (On-Site)

**The story:** Solar panels with battery storage are the cheapest form of new electricity generation on a levelized cost basis ($25/MWh in recent analyses). But there's a catch for data centers: they need power 24/7/365, and solar only produces during daytime. You'd need an enormous battery to cover nighttime and cloudy days, which changes the economics dramatically.

**Who's doing it:**

- **Aligned Data Centers:** Announced a first-of-its-kind deal for a 31MW, 62MWh battery alongside a Pacific Northwest data center, sized to allow grid interconnection years earlier than traditional utility upgrades. Planned for 2026.

- **Various hyperscalers:** Solar + storage is increasingly part of behind-the-meter configurations, particularly for operators with aggressive ESG commitments, but typically as a supplement rather than sole power source.

**Pros:** Lowest LCOE of any technology. Zero emissions during operation. No fuel costs. Modular and scalable. Relatively fast deployment (6-18 months). Can be combined with other sources.

**Cons:** Intermittent -- cannot serve 24/7 baseload alone. Would require 4-6x the data center's capacity in solar panels plus massive battery storage for true off-grid operation. Land-intensive. Battery degradation over time. Current battery technology provides 2-4 hours of storage; a data center needs 10-14 hours of overnight storage.

**Realistic role:** Supplement to gas or grid power, not a standalone solution for AI data centers. Best suited for reducing grid draw during daytime hours and potentially qualifying for clean energy credits.

### 3I. Enhanced Geothermal

**The story:** This is one of the most exciting emerging options. Enhanced Geothermal Systems (EGS) drill deep into hot rock, inject water, and use the heated water to drive turbines. Unlike solar, geothermal runs 24/7. Unlike natural gas, it's carbon-free. The breakthrough is that companies like Fervo Energy have applied horizontal drilling techniques from fracking to dramatically reduce costs and drilling times.

**Who's doing it:**

- **Google / Fervo Energy:** Google has invested in Fervo's $462M fundraising round. Fervo's Cape Station in Utah (500MW planned) will have its first 100MW phase online in late 2026. Google has also signed deals for 115MW of EGS and 150MW of conventional geothermal.

- **Google / Ormat Technologies:** In February 2026, Google signed a deal for geothermal power from Ormat.

**The breakthrough:** Fervo's drilling costs are plummeting. Their first wells took about a month; they've now completed wells in 16 days. An analysis by the Rhodium Group found that by 2030, enhanced geothermal could provide nearly two-thirds of new data center demand at costs at or below what operators pay today.

**Pros:** Carbon-free. 24/7 baseload power (like nuclear, unlike solar/wind). Small surface footprint. No fuel costs. Potentially competitive with fossil fuels by 2030. Long operational life.

**Cons:** Geographically limited (best in western US where rock is hotter). Still early-stage commercially. First commercial-scale plants are just coming online. Drilling risk. Water usage. Induced seismicity concerns (though much less than with fracking).

### 3J. Diesel/HVO Backup Generators as Bridge Power

**The story:** Every data center has diesel backup generators for emergencies. As grid connections have become bottlenecked, some operators are running these "backup" generators far more than originally intended -- using them as primary power while waiting for grid connection or on-site generation to come online.

**The regulatory friction:** Emergency generators are typically permitted for up to 100 hours per year of non-emergency operation. In Virginia (the nation's data center capital, with ~9,000 generators in the state and ~4,700 in Loudoun County alone), regulators have been wrestling with requests to expand operating hours.

**HVO (Hydrotreated Vegetable Oil)** is a drop-in replacement for diesel that can reduce greenhouse gas emissions by up to 80%. Some operators are switching to HVO to improve the emissions profile of their backup generators.

**The EPA weighed in** in May 2025, issuing new guidance clarifying when backup generators can be used to support local power supply during grid emergencies. But this doesn't solve the "backup as primary" problem.

**Pros:** Already installed at virtually every data center. Immediate availability. No new construction needed.

**Cons:** High emissions (diesel). Extremely high fuel costs for sustained operation. Not designed for continuous use. Air quality permits don't allow it. Community opposition. HVO helps with carbon but is expensive and has limited supply. Regulatory risk of operating outside permit conditions.

---

## 4. Comparison Table: All Options at a Glance {#4-comparison-table}

| Technology | Capital Cost ($/kW) | Deployment Timeline | LCOE ($/MWh) | Carbon Emissions | Reliability | Scalability | Regulatory Complexity |
|---|---|---|---|---|---|---|---|
| **Simple-cycle gas turbine** | $325-1,500 | 6-18 months | $80-120 | High (combustion) | High (99.5%+) | 25MW-300MW units | Moderate (air permits) |
| **Combined-cycle gas** | $670-2,500 | 2-4 years | $50-80 | Moderate (efficient) | Very High (99.9%) | 100MW-2GW+ | High (major permits) |
| **Fuel cells (Bloom)** | ~$7,000 | 3-6 months | $90-140 | Low (no combustion) | Very High (99.9-99.999%) | 1MW-100MW+ modular | Low-Moderate |
| **Reciprocating engines** | $500-1,200 | 6-12 months | $70-110 | High (combustion) | High | 1MW-25MW units | Moderate (air permits) |
| **Co-location (existing plant)** | Varies (PPA) | 1-3 years | $40-80 (nuclear) | Zero (if nuclear) | Very High | Limited by plant | Very High (FERC) |
| **Dedicated PPA (e.g., TMI)** | Varies (PPA) | 2-4 years | $50-90 | Zero (if nuclear) | Very High | Limited opportunities | High |
| **SMRs** | $3,000-20,000+ | 7-15 years | $89-120+ | Zero | Very High (projected) | 50-300MW per unit | Extreme (NRC) |
| **Solar + battery** | $1,200-2,500 | 6-18 months | $25-60 | Zero | Moderate (weather) | Unlimited (with land) | Low-Moderate |
| **Enhanced geothermal** | $3,000-6,000 | 2-5 years | $50-80 (projected) | Zero | High (24/7) | 10MW-500MW+ | Moderate |
| **Diesel/HVO backup** | Already installed | Immediate | $200-400 (fuel cost) | Very High (diesel) / Lower (HVO) | Moderate (not designed for continuous) | Limited | Low (if within permit) / High (if exceeding) |

**Notes on reading this table:**
- LCOE ranges are approximate and vary significantly by location, fuel prices, and project specifics.
- "Regulatory complexity" reflects both permitting and ongoing compliance burden.
- Solar + battery LCOE of $25/MWh is for solar generation alone; achieving 24/7 power would require vastly more battery storage and push effective costs much higher.
- SMR costs are highly uncertain since no commercial plants have been built.

---

## 5. The Economics: Why a 100MW Data Center Doesn't Just Build a 100MW Gas Plant {#5-the-economics}

This is one of the most frequently asked questions, and the answer is more nuanced than "it's too expensive."

### A 100MW Gas Turbine Absolutely Exists

There is no physical or engineering reason a 100MW data center can't have a 100MW gas turbine. The Mitsubishi H-100 series, for example, produces 105-116MW in simple cycle and 150-350MW in combined cycle. GE's LMS100 aeroderivative turbine produces about 100MW. These are proven, commercially available machines.

### The Real Cost

A 100MW simple-cycle gas plant would cost roughly **$50-100 million** in capital. A combined-cycle plant at that scale would be **$100-150 million**. For a hyperscaler building a $1-10 billion data center campus, this is not a prohibitive number.

### So Why Didn't They Do It Before?

**1. Grid power was cheaper and easier.** Commercial electricity rates of $40-80/MWh were cheaper than self-generation in most markets. Grid power came with no capital risk, no operating complexity, and no permitting burden. The utility handled everything.

**2. It's not just the turbine -- it's everything around it.** The gas turbine is maybe 40% of the cost. You also need:
   - A natural gas pipeline connection (can take 1-2 years to build, requires FERC approval for interstate pipelines)
   - Water supply and cooling infrastructure
   - Emissions control equipment (SCR, oxidation catalysts)
   - Staff to operate and maintain it (15-30 people for a 100MW plant)
   - Air quality permits (can take 6-18 months)
   - Fuel procurement contracts
   - Backup power for when the plant is down for maintenance

**3. Utilization matters.** A data center runs at variable load. AI training clusters may run at 95%+ utilization, but many data centers average 40-60%. A gas turbine is most efficient at full load. Running it at half load wastes fuel and increases cost per MWh.

**4. Single-customer risk.** A utility power plant spreads its costs across millions of customers. A data center's on-site plant has exactly one customer. If the data center downsizes, relocates, or the AI market shifts, the plant becomes a stranded asset. This is why utilities exist -- they pool risk.

### What Changed the Math?

Three things flipped the economics:

**1. Grid connection became the bottleneck.** When your only alternative is waiting 5-7 years for an interconnection, a $100M gas plant that takes 18 months looks like a bargain. The opportunity cost of delayed AI revenue dwarfs the capital cost of generation.

**2. AI training loads are enormous and constant.** Unlike traditional data centers with variable loads, large-scale AI training clusters run at near-100% utilization for months at a time. This makes on-site generation more economical because the plant runs at peak efficiency.

**3. Power demand went from "big" to "transformational."** When a single campus needs 1-5 GW (like Meta's Hyperion), you're no longer talking about a single data center buying power -- you're talking about building a dedicated utility-scale power infrastructure. At that scale, building your own generation starts to look like the *only* option because the existing grid literally doesn't have enough capacity.

### The Minimum Efficient Scale Question

There is no hard minimum for gas generation -- turbines come in sizes from 5MW to 500MW+. But there are scale efficiencies:

- **Below 25MW:** On-site generation rarely makes economic sense vs. grid power. The fixed costs of permitting, pipeline, and staff are too high relative to output.
- **25-100MW:** This is the "breakeven zone." On-site generation can work if grid alternatives are slow or expensive, but it's a close call.
- **100-500MW:** This is the sweet spot for dedicated on-site gas generation. You get significant economies of scale on equipment, and the campus is large enough to justify dedicated staff and infrastructure.
- **500MW+:** At this scale, you're essentially building a utility-grade power plant. This is where projects like Meta's Hyperion (2.3GW of new gas generation) operate.

The key insight: **the economics of self-generation improve dramatically as data center campuses get bigger.** A single 20MW data center building its own gas plant is probably foolish. A 2GW AI campus building its own power infrastructure is practically inevitable.

---

## 6. Regulatory Barriers {#6-regulatory-barriers}

The regulatory landscape for on-site data center generation is a patchwork of federal, state, and local rules that were never designed for this situation.

### Federal Level

**The Federal Power Act** gives FERC jurisdiction over wholesale electricity sales and transmission in interstate commerce. If your on-site generation touches the grid in any way, FERC may assert jurisdiction. This is why the co-location model at existing power plants has been so contentious -- FERC sees it as potentially affecting wholesale markets and grid reliability.

**The DATA Act (proposed, 2026)** would create a new category called "consumer-regulated electric utilities" (CREUs) exempt from the Federal Power Act -- but only if they're completely disconnected from the grid. Connect to the grid, and you lose the exemption. This is Senator Tom Cotton's attempt to create a regulatory offramp for truly off-grid data center generation.

**FERC's December 2025 Co-Location Order** directed PJM to create new transmission service categories for co-located loads and establish a 50MW threshold for behind-the-meter facilities. Loads above 50MW would be ineligible for "netting" (where behind-the-meter generation reduces your apparent grid demand). PJM has a three-year transition period to implement these rules.

**Trump's Executive Order (July 2025)** directed federal agencies to fast-track permitting for data center projects requiring more than 100MW of AI-dedicated load. It specifically called for:
- Identifying existing NEPA categorical exclusions
- Creating new categorical exclusions for qualifying projects
- Making federal lands (including brownfield/Superfund sites and DOE national labs) available for data centers
- Streamlining natural gas, coal, nuclear, and geothermal permitting

Four DOE national lab sites were immediately identified: Idaho National Laboratory, Oak Ridge (TN), Paducah (KY), and Savannah River (SC).

### State Level

**Utility Franchise Laws:** Most states grant utilities an exclusive franchise to serve customers in their territory. Building your own generation to serve your own load is generally permitted (known as "self-generation"), but selling excess power or serving other tenants at a data center campus can run afoul of franchise laws.

**Air Quality Permits:** This is often the most immediate barrier. Gas turbines and engines require air permits under the Clean Air Act. The permitting process varies by state:
- **Minor source permits:** For smaller or lower-emitting facilities. Faster to obtain but with strict emissions caps.
- **Major source permits (Title V):** Required when emissions exceed certain thresholds (e.g., 100 tons/year of NOx). These require public notice, comment periods, and can take 12-18 months.
- xAI's Memphis controversy illustrated what happens when you get this wrong: they allegedly operated with the wrong permit type, triggering community backlash and legal challenges.

**State Data Center Legislation (2026):** More than 300 state bills have been filed across 30+ states in just the first six weeks of 2026, marking a shift from incentive-focused policies to regulatory oversight. Many of these address energy and environmental impacts.

**Virginia** (the nation's largest data center market) is a particular hotspot:
- Virginia DEQ released new air permitting guidance documents specifically for data centers
- Emergency generators are allowed up to 100 hours/year for non-emergency use, with total operating hours capped at 500/year
- Proposed rule changes to expand diesel generator usage have faced strong community opposition

### Local Level

**Zoning:** Many data centers are being built in rural areas not zoned for industrial power generation. Adding a gas plant to a data center campus may require rezoning.

**Noise ordinances:** Gas turbines are loud. Compliance with local noise limits requires expensive sound attenuation.

**Water permits:** Combined-cycle plants and some cooling systems require water withdrawal permits.

---

## 7. Recent News and Trends (2025-2026) {#7-recent-news}

### The Biggest Stories

**Meta's Hyperion Keeps Growing (February 2026):** Meta quietly expanded its Louisiana AI campus to roughly four times the size of Manhattan's Central Park. Entergy is building 2.3GW of new gas generation at ~$4 billion. Meta formed a $27 billion joint venture with Blue Owl to fund the campus, with Blue Owl owning 80% and Meta retaining 20%.

**Ratepayer Protection Pledge (March 2026):** The Trump administration brought Amazon, Google, Meta, Microsoft, OpenAI, Oracle, and xAI together to sign a pledge committing to "build, bring, or buy new generation resources and cover the cost of all power delivery infrastructure." This is the clearest signal yet that the federal government expects tech companies to solve their own power problems.

**FERC Co-Location Order (December 2025):** FERC ordered PJM to develop rules for large-load co-location at power plants, creating three new transmission service categories. The 50MW threshold for behind-the-meter facilities will reshape how data centers interact with the grid. PJM's December 2025 capacity auction fell 6,623 MW short of its reliability target, with data centers responsible for nearly 5,100 MW of the demand surge.

**Amazon/Talen Restructured Deal (June 2025):** After FERC denied the behind-the-meter model twice, Talen restructured the Susquehanna deal into a 17-year, $18 billion front-of-the-meter PPA supplying up to 1,920MW to Amazon. This is likely the template for future nuclear-data center arrangements.

**Constellation/TMI Loan (December 2025):** DOE closed a $1 billion loan to support Constellation's restart of Three Mile Island Unit 1 for Microsoft. Target restart: 2028.

**Amazon's Expanded SMR Plans (October 2025):** Amazon unveiled plans for 12 SMRs in Washington state (up from the original 4), producing up to 960MW. Construction expected by end of this decade.

**Fervo Energy's $462M Raise (December 2025):** Google invested in Fervo's fundraise to expand enhanced geothermal. Cape Station's first 100MW phase targeted for late 2026.

**Bloom Energy Scaling to 2GW (2026):** On track to double annual production capacity to 2GW, reflecting surging data center demand.

**INNIO/VoltaGrid 2.3GW Order (2025):** The largest order in INNIO's history -- 92 power packs of 25MW each, purpose-built for data center deployment.

**The DATA Act (Proposed, 2026):** Senator Cotton's bill would exempt off-grid data center generation from Federal Power Act requirements, creating a new regulatory category.

### Emerging Themes

1. **Natural gas is winning the near-term race.** The U.S. tripled the amount of gas-fired generation capacity in development in 2025, with more than a third tied directly to on-site data center generation. This is the dominant behind-the-meter technology for the next 3-5 years.

2. **Nuclear is the long-term bet.** Big tech has signed contracts for more than 10GW of new US nuclear capacity. But timelines are long (2028-2035+), costs are uncertain, and regulatory approval is not guaranteed.

3. **Fuel cells are the dark horse.** Bloom Energy's ability to deploy 100MW in 120 days makes it uniquely suited to bridge the gap between "we need power now" and "our permanent solution is years away."

4. **The regulatory framework is being rebuilt in real time.** FERC, Congress, state legislatures, and the White House are all simultaneously trying to create rules for a situation nobody anticipated five years ago.

5. **The grid isn't going away.** Even companies pursuing aggressive on-site generation still need grid connections for redundancy, startup power, and load balancing. The question is shifting from "grid vs. on-site" to "what's the right mix?"

6. **Environmental justice is a growing concern.** The xAI Memphis situation put the environmental impact of on-site gas generation in the spotlight. Expect more community opposition and stricter permitting as these projects proliferate, particularly in disadvantaged communities.

---

## 8. Sources {#8-sources}

### Regulatory and Policy
- [FERC Orders PJM to Craft Large Load Colocation Rules](https://www.utilitydive.com/news/ferc-pjm-colocation-data-center/808368/) - Utility Dive
- [FERC Fact Sheet: Directs PJM to Create New Rules](https://www.ferc.gov/news-events/news/fact-sheet-ferc-directs-nations-largest-grid-operator-create-new-rules-embrace) - FERC
- [Data Center Energy Infrastructure: Federal Permit Requirements](https://www.congress.gov/crs-product/R48762) - Congress.gov
- [Trump Administration Executive Order on Data Center Permitting](https://www.whitehouse.gov/presidential-actions/2025/07/accelerating-federal-permitting-of-data-center-infrastructure/) - White House
- [Ratepayer Protection Pledge Fact Sheet](https://www.whitehouse.gov/fact-sheets/2026/03/fact-sheet-president-donald-j-trump-advances-energy-affordability-with-the-ratepayer-protection-pledge/) - White House
- [State Energy Regulatory Approaches to Powering Data Centers](https://www.pillsburylaw.com/en/news-and-insights/powering-data-centers-state-regulatory.html) - Pillsbury Law
- [DATA Act Proposal](https://www.datacenterdynamics.com/en/news/us-senator-proposes-bill-permitting-ai-data-centers-to-bypass-federal-power-rules-via-off-grid-energy-infrastructure-development/) - DCD
- [Unpacking Trump's Directive to Build Own Power Plants](https://deeptech.duke.edu/blog-post/unpacking-president-trumps-directive-big-tech-build-their-own-power-plants/) - Duke Deep Tech
- [FERC Denies Talen-Amazon Agreement](https://www.ans.org/news/2025-04-16/article-6937/ferc-denies-talen-amazon-agreementagain/) - ANS Nuclear Newswire
- [State Data Center Legislation in 2026](https://www.multistate.us/insider/2026/2/20/state-data-center-legislation-in-2026-tackles-energy-and-tax-issues) - MultiState

### Natural Gas On-Site Generation
- [Onsite Gas Turbines to Power Meta Data Center](https://www.power-eng.com/onsite-power/onsite-gas-turbines-reciprocating-engines-to-power-meta-data-center/) - Power Engineering
- [More Data Centers Plan to Build Own Natural Gas Plants](https://www.marketplace.org/story/2026/02/04/more-data-centers-plan-to-build-their-own-natural-gas-plants-for-power) - Marketplace
- [Data Centers Scrambling to Power AI Boom with Natural Gas](https://grist.org/energy/data-centers-natural-gas-methane-behind-the-meter/) - Grist
- [Bridging the 5-Year Gap: Off-Grid Gas Power for Data Centers](https://www.woodwayenergy.com/off-grid-btm-gas-power-generation-data-centers/) - Woodway Energy
- [Engine Power Plants Surge as Data Centers Drive Demand](https://www.powermag.com/engine-power-plants-surge-as-data-centers-drive-unprecedented-demand/) - Power Magazine
- [Data Center Developers Turn to Distributed BTM Power](https://www.spglobal.com/market-intelligence/en/news-insights/articles/2025/10/data-center-developers-turn-to-distributed-behind-the-meter-power-94174247) - S&P Global

### Meta Hyperion
- [The Power Play Behind Hyperion](https://sherwood.news/tech/hyperion/) - Sherwood News
- [Meta $10 Billion Louisiana Data Center](https://fortune.com/2025/08/24/meta-data-center-rural-louisiana-framework-ai-power-boom/) - Fortune
- [Meta Expanding Hyperion](https://fortune.com/2026/02/04/meta-hyperion-ai-data-center-louisiana-expansion/) - Fortune
- [Meta $27B Joint Venture with Blue Owl](https://www.datacenterdynamics.com/en/news/meta-forms-27-billion-joint-venture-with-blue-owl-to-fund-gigawatt-scale-ai-data-center-campus-in-louisiana/) - DCD

### xAI Memphis
- [xAI Removes Gas Turbines from Memphis](https://www.datacenterdynamics.com/en/news/xai-removes-some-of-controversial-gas-turbines-from-memphis-data-center/) - DCD
- [xAI Gas Turbines Without Permits](https://insideclimatenews.org/news/17072025/elon-musk-xai-data-center-gas-turbines-memphis/) - Inside Climate News
- [xAI Permit for Gas Turbines](https://www.cnbc.com/2025/07/03/musks-xai-gets-permit-for-turbines-to-power-supercomputer-in-memphis.html) - CNBC

### Nuclear (Existing and SMRs)
- [Microsoft Three Mile Island 835MW PPA](https://www.datacenterdynamics.com/en/news/three-mile-island-nuclear-power-plant-to-return-as-microsoft-signs-20-year-835mw-ai-data-center-ppa/) - DCD
- [Big Tech Embraces Nuclear Power](https://spectrum.ieee.org/nuclear-powered-data-center) - IEEE Spectrum
- [Amazon 12 SMRs in Washington](https://www.nucnet.org/news/amazon-unveils-updated-plans-for-12-small-modular-reactors-in-washington-10-5-2025) - NucNet
- [Big Tech's Nuclear Bet: Key SMRs](https://www.wwt.com/blog/big-techs-nuclear-bet-key-small-modular-reactors-for-cloud-power) - WWT
- [NuScale Cost Estimates](https://ieefa.org/resources/eye-popping-new-cost-estimates-released-nuscale-small-modular-reactor) - IEEFA

### Fuel Cells
- [Bloom Energy: AI Revolution and Data Center Power](https://www.bloomenergy.com/blog/the-ai-revolution-how-fuel-cells-are-solving-the-data-center-power-challenge/) - Bloom Energy
- [Bloom Energy 2GW Production Capacity](https://www.utilitydive.com/news/bloom-energy-says-its-on-track-for-2-gw-annual-production-capacity/804291/) - Utility Dive
- [Oracle and Bloom Energy Collaboration](https://investor.bloomenergy.com/press-releases/press-release-details/2025/Oracle-and-Bloom-Energy-Collaborate-to-Deliver-Power-to-Data-Centers-at-the-Speed-of-AI/default.aspx) - Bloom Energy
- [Fuel Cells Could Help Meet Data Center Demand](https://www.goldmansachs.com/insights/articles/fuel-cells-could-help-meet-the-power-demand-from-data-centers) - Goldman Sachs
- [Bloom Energy 2026 Power Report](https://investor.bloomenergy.com/press-releases/press-release-details/2026/Data-Centers-Plan-to-Reduce-Reliance-on-Grid-Finds-Bloom-Energys-2026-Power-Report/default.aspx) - Bloom Energy

### Solar, Battery, and Geothermal
- [Data Centers Beginning to Embrace Batteries](https://www.latitudemedia.com/news/data-centers-are-beginning-to-embrace-batteries-for-onsite-power/) - Latitude Media
- [Behind-the-Meter Power Solutions](https://datacenterhawk.com/resources/market-insights/behind-the-meter-power-solutions-the-data-center-industry-s-new-reality) - datacenterHawk
- [Fervo Energy Enhanced Geothermal Data Center Corridor](https://fervoenergy.com/fervo-uipa-the-enhanced-geothermal-data-center-corridor-july-2025/) - Fervo Energy
- [Google Invests in Fervo's $462M Round](https://techcrunch.com/2025/12/10/google-invests-in-fervos-462m-round-to-unlock-even-more-geothermal-energy/) - TechCrunch
- [Google Ormat Geothermal Deal](https://www.theregister.com/2026/02/18/google_ormat_geothermal_datacenter_deal) - The Register

### Diesel/Backup Generators
- [Data Centers' Diesel Generators Commonplace and Problematic](https://insideclimatenews.org/news/12112025/data-center-diesel-generators-noise-pollution/) - Inside Climate News
- [Virginia Regulators Weigh Expanded Diesel Generator Use](https://www.vpm.org/news/2025-12-17/virginia-data-centers-diesel-backup-generators-deq-loudoun-turner-dowd) - VPM
- [EPA Guidance on Backup Generators](https://www.kirkland.com/publications/kirkland-alert/2025/05/new-epa-guidance-clarifies-when-data-centers-and-other-operators-may-utilize-emergency-backup) - Kirkland & Ellis

### Economics and Cost Analysis
- [Gas Turbine Costs $/kW](https://gasturbineworld.com/gas-turbine-costs-kw/) - Gas Turbine World
- [Lazard LCOE+ June 2025](https://www.lazard.com/media/uounhon4/lazards-lcoeplus-june-2025.pdf) - Lazard
- [LCOE Comparative Analysis for Data Centers](https://www.sciencedirect.com/science/article/pii/S2352484725005803) - ScienceDirect
- [Electricity Costs and Data Centers](https://www.opb.org/article/2026/02/13/as-electricity-costs-rise-everyone-wants-data-centers-to-pick-up-their-tab-but-how/) - OPB
