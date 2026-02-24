# Build a Writer's Voice Profile from Writing Samples

## Problem/Feature Description

Nadia Okafor is a DevOps engineer who writes a personal blog about infrastructure and observability. She wants to set up a writing persona profile that captures her voice so that future writing assistance stays consistent with her natural style.

She's providing three of her published blog post excerpts below. Analyze these samples to identify her voice patterns, rhetorical devices, humor style, cultural references, technical depth habits, and any recurring characters or elements. Then generate a set of persona files that capture her voice.

Her basic info:
- **Name:** Nadia Okafor
- **Role:** Senior DevOps Engineer at Meridian Health
- **Career context:** Previously ran infrastructure for a gaming company that scaled from 10K to 2M concurrent users
- She wants a rotating bio kicker (a dry observation that changes per post)
- She does NOT write about a specific product, so skip product context

## Output Specification

Produce the following files in a `persona/` directory:
- `persona/voice.md` -- voice profile with analysis of her writing patterns
- `persona/bio.md` -- author bio template with schema, examples, and kicker notes
- `persona/examples.md` -- catalog of the writing samples with notes on what each demonstrates about her voice

## Input Files

The following files are provided as inputs. Extract them before beginning.

=============== FILE: inputs/sample-1.txt ===============
TITLE: The Dashboard That Cried Wolf
SOURCE: https://nadia.dev/dashboard-cried-wolf

We had 847 alerts fire in January. I know because I counted. (I counted because I was trying to prove a point to my manager, and the point backfired spectacularly.)

Of those 847 alerts, exactly 12 required human intervention. The rest were noise -- CPU spikes that resolved themselves, disk usage that triggered at 80% on volumes that auto-expand, and my personal favorite: a "database connection pool exhausted" alert that fired every time our nightly ETL job ran. Every. Single. Night. For eight months.

Nobody turned it off because nobody was sure it wasn't important. This is the ops equivalent of that one smoke detector in your apartment that chirps at 3 AM -- you KNOW it's just the battery, but what if this time it's actually fire?

So I did what any reasonable person would do: I built a spreadsheet. Three columns. Alert name, action taken, resolution. I logged every alert for 30 days. My teammates thought I'd lost it. My manager asked if I was "feeling okay." Prashant -- our junior engineer who had just rotated onto the on-call schedule and was, understandably, questioning his career choices -- started calling it "The Spreadsheet of Truth."

The results were damning. We had a 1.4% signal-to-noise ratio on our alerts. Put another way: for every real problem, we generated 70 false alarms. If this were a hospital, we'd have lost our license.

I deleted 200 alerts in one afternoon. Just... deleted them. If you've never done this, I highly recommend it. It's terrifying and cathartic in equal measure. Like throwing away clothes you haven't worn in three years -- you KNOW you don't need them, but what if there's a formal event?

The on-call rotation went from "please god not me" to "yeah, I'll take Tuesday." Prashant stopped questioning his career choices. Temporarily.

The real lesson isn't "delete your alerts." It's that we built monitoring for hypothetical failures instead of observed ones. We were defending against an imaginary siege while the actual intruders walked through the front door.
=============== END SAMPLE 1 ===============

=============== FILE: inputs/sample-2.txt ===============
TITLE: Terraform State and the Art of Not Panicking
SOURCE: https://nadia.dev/terraform-state-calm

I corrupted the Terraform state file on a Thursday. (It's always Thursday. Fridays are for reading the postmortem you wrote about Thursday.)

To be specific: I ran terraform import on a resource that was already managed, didn't realize it would overwrite the existing state entry, and suddenly our production load balancer existed in a quantum superposition of "managed" and "not managed." Schrodinger's ALB.

My first instinct was to fix it immediately. My second instinct -- the one I actually followed, because I've been doing this long enough to know that first instincts at 4 PM on a Thursday are how you end up with TWO corrupted state files -- was to stop, breathe, and open the state backup.

Here's the thing about Terraform state that nobody tells you when you're learning: the state file is not a nice-to-have. It IS the infrastructure, as far as Terraform is concerned. Your actual AWS account could have 200 perfectly healthy resources, but if the state file says there are 199, Terraform will helpfully offer to create the missing one. Again. On top of the existing one. In production.

I restored from the S3 versioned backup (if you're not versioning your state backend, stop reading this and go set that up; I'll wait) and diffed the corrupted version against the backup. The damage was limited to three resources.

Prashant -- who had been watching from across the desk with the expression of a man witnessing a car accident in slow motion -- asked if he should "do anything." I told him to document what I was doing, because I was going to write this blog post and I knew I'd forget the details by Monday.

The fix took 20 minutes. The state file recovered perfectly. The only lasting damage was to my ego and to Prashant's already fragile confidence in infrastructure-as-code.

I now have a pre-import checklist taped to my monitor. Step one: "Is it Thursday? If yes, maybe wait until tomorrow."
=============== END SAMPLE 2 ===============

=============== FILE: inputs/sample-3.txt ===============
TITLE: Why I Stopped Writing Runbooks and Started Writing Scripts
SOURCE: https://nadia.dev/runbooks-to-scripts

Runbooks are lies we tell ourselves.

I don't mean that maliciously. Runbooks are well-intentioned. Someone has an incident, figures out how to fix it, and writes down the steps so the next person doesn't have to figure it out again. Noble. Practical. And completely useless three months later when the infrastructure has changed and step 4 ("click the blue button in the AWS console") now refers to a button that is green and has moved to a different page.

Our runbook for "database failover" had 23 steps. I know because I followed them during an actual failover at 2 AM and discovered that steps 8 through 14 referenced a dashboard we'd decommissioned in September. The runbook was last updated in June. It was now February.

I did what the runbook couldn't: I improvised. Badly. The failover took 45 minutes instead of the documented 15. Prashant was on the call with me (because misery loves company and also because he was on-call secondary) and at minute 30 he said something that stuck: "If the computer is supposed to do these steps, why are we doing them?"

He was right. The dirty secret of runbooks is that they describe things a computer should be doing. If a procedure can be written as sequential steps with predictable inputs and outputs, it can be a script. If it CAN'T be a script, then it requires judgment, and no runbook captures judgment -- it captures the LAST person's judgment in the LAST context, which is almost certainly not your context right now.

I spent the next two weeks converting our top 10 runbooks into executable scripts. Not fancy orchestration -- just bash scripts with error handling and Slack notifications. The database failover? Seven minutes, automated, tested monthly. (I tested it monthly because Prashant made me promise. He has a long memory for 2 AM incidents.)

We kept the runbooks, but they changed. Instead of step-by-step procedures, they became decision trees: "If X, run script Y. If Z, escalate to Nadia because this is the scenario we haven't automated yet and honestly it might require crying."

The on-call engineers stopped dreading incidents. Not because incidents stopped happening, but because the response was now "run the script" instead of "follow these 23 steps and hope steps 8-14 still apply."
=============== END SAMPLE 3 ===============
