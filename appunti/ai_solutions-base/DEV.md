# DEV

Quick Start

# Esportiamo i token come variabili di ambiente

> export MY_HF_TOKEN=hf_xxxxxxxxxxxxxxxxxx
>
> export MY_OVHAI_ACCESS_TOKEN=XXXXXXXXXXXXXXXXXX

```bash
source scripts/ovhrc.sh
```

# Eseguiamo modelli LLM come applicazioni private AI Deploy

## Per il modello mistral

```bash
./scripts/ovhai_deploy-vllm-mistral_small.sh
```

Esportiamo l'**App ID** per il modello **mistral** AI Deploy
```bash
#export OVHAI_APP_ID_MISTRAL=ce566c85-a989-4294-8d40-8b035d5f3e32
export OVHAI_APP_ID_MISTRAL=11c0ef55-6b44-4a12-9875-7ef89b437ae6
```

## Per il modello deepseek

```bash
./scripts/ovhai_deploy-vllm-deepseek_xsmall.sh
```

Esportiamo l'**App ID** per il modello **deepseek** AI Deploy
```bash
#export OVHAI_APP_ID_DEEPSEEK=xxxxx
export OVHAI_APP_ID_DEEPSEEK=d7ceef93-ccd1-4ee8-b548-352f3672a728
```

# Stato e log dell'App ID

Visualizziamo lo stato e la configurazione dell'**App ID** per i modelli AI Deploy
```bash
#ovhai app logs $OVHAI_APP_ID_MISTRAL
/Users/dletizia/bin/ovhai app get $OVHAI_APP_ID_MISTRAL
```
```bash
#ovhai app logs $OVHAI_APP_ID_DEEPSEEK
/Users/dletizia/bin/ovhai app get $OVHAI_APP_ID_DEEPSEEK
```

Visualizziamo i log dell'**App ID** per i modelli AI Deploy
```bash
#ovhai app logs $OVHAI_APP_ID_MISTRAL
/Users/dletizia/bin/ovhai app logs $OVHAI_APP_ID_MISTRAL
```
```bash
#ovhai app logs $OVHAI_APP_ID_DEEPSEEK
/Users/dletizia/bin/ovhai app logs $OVHAI_APP_ID_DEEPSEEK
```

# cURL per interrogare i modelli serviti con AI Deploy

## Per il modello mistral
```bash
curl https://$OVHAI_APP_ID_MISTRAL.app.gra.ai.cloud.ovh.net/v1/chat/completions \
    -H "Authorization: Bearer $MY_OVHAI_ACCESS_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
        "model": "mistralai/Mistral-Small-24B-Instruct-2501",
        "messages": [
            {"role": "system", "content": "You are a helpful assistant."},
            {"role": "user", "content": "Give me the name of OVHcloud’s founder."}
        ],
        "stream": false
    }'

```

Ritornerà un risultato simile al seguente
```json
{
    "id":"chatcmpl-5817e2febf86fda42b99328954485940",
    "object":"chat.completion",
    "created":1741521522,
    "model":"mistralai/Mistral-Small-24B-Instruct-2501",
    "choices":[{
        "index":0,
        "message":{
            "role":"assistant",
            "reasoning_content":null,
            "content":"The founder of OVHcloud is Octave Klaba. He started the company in 1999, and it has since grown to become one of the world's leading cloud service providers.",
            "tool_calls":[]
        },"logprobs":null,
        "finish_reason":"stop",
        "stop_reason":null
    }],
    "usage":{
        "prompt_tokens":22,
        "total_tokens":63,
        "completion_tokens":41,
        "prompt_tokens_details":null
    },
    "prompt_logprobs":null
}
```

## Per il modello deepseek
```bash
curl https://$OVHAI_APP_ID_DEEPSEEK.app.gra.ai.cloud.ovh.net/v1/chat/completions \
    -H "Authorization: Bearer $MY_OVHAI_ACCESS_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
        "model": "deepseek-ai/DeepSeek-R1-Distill-Qwen-7B",
        "messages": [
            {"role": "system", "content": "You are a helpful assistant."},
            {"role": "user", "content": "Give me the name of OVHcloud’s founder."}
        ],
        "stream": false
    }'

```

Ritornerà un risultato simile al seguente
```json
{
    "id":"chatcmpl-ae2a1430aa006eed7cad15ffe8eea50c",
    "object":"chat.completion",
    "created":1741528553,
    "model":"deepseek-ai/DeepSeek-R1-Distill-Qwen-7B",
    "choices":[{
        "index":0,
        "message":{
            "role":"assistant",
            "reasoning_content":null,
            "content":"Alright, so I need to figure out the name of OVHcloud's founder. I'm not exactly sure who OVHcloud is, but I think it's related to cloud services. Let me start by breaking this down.\n\nFirst, \"OVHcloud\" sounds French, so maybe the founder has a French name. The user's previous response mentioned that Ophélie завис金 is the founder, which makes sense given the French ending. But I should verify if that's correct.\n\nI can start by recalling that OVHcloud is a European cloud service provider. They offer various cloud computing services, similar to AWS or Microsoft Azure. Now, to find the founder's name, I might search online or check OVHcloud's official website, but since I can't browse the web, I have to rely on my existing knowledge.\n\nFrom what I know, OVHcloud was founded by a team, and the main founder is a woman, so her name likely reflects that. The name Ophélie is common in France, so it's plausible. The name also includes a last name; depending on French naming conventions, it might be something likeԺ dependent or金. The family name \" завис金\" translates to \"cup.\"\n\nPutting it together, the founder's name is probably Ophélie зависим金. I think that's the correct name based on the information I have. To be thorough, I could recall that OVHcloud was established in 2004, and dependent on financial stability, so the founder would have managed the growth and operations of the company.\n\nAlso, considering OVHcloud's services include hosting, serverless computing, and DevOps tools, the founder must have expertise in the IT sector, possibly in cloud infrastructure. This expertise would have driven the success of the company.\n\nI should also check if there are any other notable figures associated with OVHcloud. Looking back, there was also a founder involved with OVHService, which is a different company. However, for OVHcloud specifically, dependent on the info I have, Ophélie зависим金 is the name.\n\nIn summary, by piecing together the French naming conventions and the nature of the company, the founder's name is Ophéliedependent金.\n
            </think>
            \n\nThe founder of OVHcloud is Ophélie зависим金.",
            "tool_calls":[]
        },
        "logprobs":null,
        "finish_reason":"stop",
        "stop_reason":null
    }],
    "usage":{
        "prompt_tokens":22,
        "total_tokens":498,
        "completion_tokens":476,
        "prompt_tokens_details":null
    },
    "prompt_logprobs":null
}
```

# cURL per interrogare i modelli serviti con AI Endpoints

Il modo più rapido per testare DeepSeek-R1 è utilizzare gli AI Endpoint di OVHcloud.

DeepSeek-R1-Distil-Llama-70B è già disponibile, pronto all'uso e ottimizzato per la velocità di inferenza. Consulta la pagina qui: https://endpoints.ai.cloud.ovh.net/models/a011515c-0042-41b2-9a00-ec8b5d34462d

Gli AI Endpoint semplificano l’integrazione dell’IA nelle applicazioni con una semplice chiamata API, senza la necessità di una profonda competenza in materia di IA o di una gestione dell’infrastruttura. E mentre è in beta, è gratis!

Ecco un esempio di comando cURL per utilizzare DeepSeek-R1 Distil Llama 70B sull’endpoint compatibile con OpenAI fornito da OVHcloud AI Endpoints:

```bash
curl -X 'POST' \
    'https://deepseek-r1-distill-llama-70b.endpoints.kepler.ai.cloud.ovh.net/api/openai_compat/v1/chat/completions' \
    -H 'accept: application/json' \
    -H 'Content-Type: application/json' \
    -d '{
    "max_tokens": 4096,
    "messages": [
        {
            "content": "How can I calculate an approximation of Pi in Python?",
            "role": "user"
        }
    ],
    "model": null,
    "seed": null,
    "stream": false,
    "temperature": 0.7,
    "top_p": 1
    }'

```

Ritornerà un risultato simile al seguente
```json
{
    "id":"chatcmpl-6d5ba1a6405c42b89c593bde5a4464cf",
    "object":"chat.completion",
    "created":1741531041,
    "model":"DeepSeek-R1-Distill-Llama-70B",
    "choices":[{
        "index":0,"message":{
            "role":"assistant",
            "content":"
            <think>
            \n
            Okay, so I need to figure out how to approximate Pi using Python. I'm pretty new to both Python and math, so I'll take it step by step. Let me think about what I know regarding Pi and possible methods to calculate it.\n\nPi is the ratio of a circle's circumference to its diameter, approximately 3.14159. There are various ways to approximate Pi, both geometrically and numerically. I remember hearing about the Leibniz formula and the Monte Carlo method, so maybe I can try those.\n\nFirst, the Leibniz formula for Pi is an infinite series: Pi/4 = 1 - 1/3 + 1/5 - 1/7 + 1/9 - ... and so on. This is an alternating series, and each term gets smaller, so adding more terms should give a better approximation. The more terms I include, the closer I get to Pi/4, and then I just multiply by 4 to get Pi.\n\nSo, for the Leibniz method, I can write a loop that adds and subtracts these fractions. I'll need a variable to keep track of the sum, starting at 0. Then, for each iteration, I add the next positive term and subtract the next negative term. Wait, actually, looking at the series, it's 1 - 1/3 + 1/5 - 1/7 + ..., so each term alternates sign. Maybe I can use a variable that alternates between adding and subtracting each term.\n\nAlternatively, I could use a step where each term is 1/(2n-1), multiplied by (-1)^(n+1). Hmm, that might be a more concise way. So for n starting at 1, the nth term is (-1)^(n+1)/(2n-1). Then, the sum of these terms multiplied by 4 gives Pi.\n\nLet me outline that:\n\n1. Initialize sum as 0.\n2. For each n from 1 to a large number (like 1000000):\n   a. Calculate term = (-1)^(n+1)/(2n - 1)\n   b. Add term to sum\n3. Multiply sum by 4 to get Pi.\n\nBut wait, in Python, exponents can be handled with **, but since n can be large, I might need to consider performance. However, for the sake of approximation, even a million terms should be manageable.\n\nNow, the Monte Carlo method is another approach. It's a probabilistic method where you simulate random points and calculate the proportion that fall inside a circle. The steps would be:\n\n1. Generate a large number of random points within a square (say, from -1 to 1 in both x and y axes).\n2. For each point, check if it's inside the unit circle (x^2 + y^2 <= 1).\n3. The ratio of points inside the circle to the total points approximates the area of the circle, which is Pi/4. So, multiply this ratio by 4 to estimate Pi.\n\nLet's break this down:\n\n- I can generate random points using the random module in Python. Specifically, random.uniform(-1, 1) for both x and y coordinates.\n- For each point, calculate x**2 + y**2 and check if it's less than or equal to 1. If yes, increment the count.\n- After generating all points, Pi is approximately 4 * (number of points inside circle) / (total number of points).\n\nI think using a million points would give a decent approximation, but it's computationally intensive. Maybe 100,000 points would be enough for a basic approximation.\n\nNow, considering the Leibniz method, it converges slowly. Even with a million terms, the approximation might not be very precise. The Monte Carlo method is more of a simulation and also doesn't give a very accurate result without a huge number of points, but it's a fun way to approximate Pi.\n\nAlternatively, there are other series that converge faster, like the Nilakantha series: Pi = 3 + 4/(2*3*4) - 4/(4*5*6) + 4/(6*7*8) - ... which might converge faster than Leibniz. But I'm more familiar with Leibniz, so I'll stick with that for now.\n\nLet me outline the code structure for both methods.\n\nFor the Leibniz method:\n\n- Initialize sum_pi to 0.\n- Loop over a large number of terms, say n from 1 to N (like 1,000,000).\n- For each n, calculate the term as (-1)**(n+1)/(2*n - 1).\n- Add this term to sum_pi.\n- After the loop, multiply sum_pi by 4 to get Pi.\n- Print the result.\n\nIn Python code, that would be something like:\n\nimport math\n\nn_terms = 1000000\nsum_pi = 0.0\nfor n in range(1, n_terms + 1):\n    term = (-1) ** (n + 1) / (2 * n - 1)\n    sum_pi += term\npi_approx = 4 * sum_pi\nprint(pi_approx)\n\nBut wait, in Python, the exponent operator is **, so (-1) ** (n+1) will alternate between 1 and -1. That seems correct.\n\nAlternatively, I can use a step to alternate signs without using exponentiation, but this is straightforward.\n\nFor the Monte Carlo method:\n\n- Import random.\n- Set the number of points, say num_points = 1000000.\n- Initialize inside_circle = 0.\n- Loop num_points times:\n   - Generate x = random.uniform(-1, 1)\n   - Generate y = random.uniform(-1, 1)\n   - If x**2 + y**2 <= 1, increment inside_circle by 1.\n- pi_approx = 4 * inside_circle / num_points\n- Print pi_approx.\n\nIn code:\n\nimport random\n\nnum_points = 1000000\ninside_circle = 0\n\nfor _ in range(num_points):\n    x = random.uniform(-1, 1)\n    y = random.uniform(-1, 1)\n    if x**2 + y**2 <= 1:\n        inside_circle += 1\n\npi_approx = 4 * inside_circle / num_points\nprint(pi_approx)\n\nI think that's correct. However, due to the nature of random sampling, this might not be as accurate as the Leibniz method with a million terms, but it's a good approximation.\n\nNow, considering possible issues: For the Leibniz method, using a large number of terms might take some time, but Python can handle it. Also, with 1,000,000 terms, the approximation is decent, but not extremely precise. The Monte Carlo method depends on the number of points; more points give a better approximation, but it's also more computationally heavy.\n\nI wonder if there's a way to make the Leibniz method converge faster. Maybe using a different series or adding more terms. Alternatively, I could use the Bailey–Borwein–Plouffe formula, which is a spigot algorithm, but that's more complex. Since I'm a beginner, the Leibniz and Monte Carlo methods are more accessible.\n\nAnother thought: Perhaps using the math library's functions to compute Pi and comparing the approximation with the actual value to see the error. For example, after computing pi_approx, calculate the difference between pi_approx and math.pi to see how accurate it is.\n\nSo, in the Leibniz code:\n\nimport math\n\nn_terms = 1000000\nsum_pi = 0.0\nfor n in range(1, n_terms + 1):\n    term = (-1) ** (n + 1) / (2 * n - 1)\n    sum_pi += term\npi_approx = 4 * sum_pi\nerror = abs(pi_approx - math.pi)\nprint(f\"Approximation: {pi_approx}\")\nprint(f\"Error: {error}\")\n\nSimilarly for the Monte Carlo method:\n\nimport random\nimport math\n\nnum_points = 1000000\ninside_circle = 0\n\nfor _ in range(num_points):\n    x = random.uniform(-1, 1)\n    y = random.uniform(-1, 1)\n    if x**2 + y**2 <= 1:\n        inside_circle += 1\n\npi_approx = 4 * inside_circle / num_points\nerror = abs(pi_approx - math.pi)\nprint(f\"Approximation: {pi_approx}\")\nprint(f\"Error: {error}\")\n\nThis way, I can see how close the approximation is to the actual Pi.\n\nI should also consider the time it takes to run these scripts. The Leibniz method with a million terms might take a few seconds, while the Monte Carlo method with a million points could take longer because of the random number generation and the distance calculation for each point.\n\nAnother idea: Maybe using numba or other optimization techniques to speed up the loops, but as a beginner, I might not be familiar with that yet. So, perhaps using a smaller number of terms or points for a faster approximation, though it would be less accurate.\n\nIn conclusion, both methods are viable for approximating Pi, each with their pros and cons. The Leibniz method is more straightforward in code and converges systematically, while the Monte Carlo method is a probabilistic approach that can be parallelized more easily, though it's generally slower for high precision.\n\nI think I've covered the main points. Now, I'll write the code for both methods, making sure to include comments and necessary imports.
            \n
            </think>
            \n\n
            To approximate Pi in Python, you can use either the Leibniz formula or the Monte Carlo method. Here's how you can implement both:\n\n### Using the Leibniz Formula\n\nThe Leibniz formula is an infinite series that converges to Pi/4. By summing a large number of terms, you can approximate Pi.\n\n```python\nimport math\n\ndef approximate_pi_leibniz(n_terms):\n    sum_pi = 0.0\n    for n in range(1, n_terms + 1):\n        term = (-1) ** (n + 1) / (2 * n - 1)\n        sum_pi += term\n    pi_approx = 4 * sum_pi\n    return pi_approx\n\n# Example usage\nn_terms = 1000000\npi_approx = approximate_pi_leibniz(n_terms)\nprint(f\"Approximation of Pi: {pi_approx}\")\nprint(f\"Error: {abs(pi_approx - math.pi)}\")\n```\n\n### Using the Monte Carlo Method\n\nThe Monte Carlo method approximates Pi by simulating random points and calculating the proportion inside a circle.\n\n```python\nimport random\nimport math\n\ndef approximate_pi_monte_carlo(num_points):\n    inside_circle = 0\n    for _ in range(num_points):\n        x = random.uniform(-1, 1)\n        y = random.uniform(-1, 1)\n        if x**2 + y**2 <= 1:\n            inside_circle += 1\n    pi_approx = 4 * inside_circle / num_points\n    return pi_approx\n\n# Example usage\nnum_points = 1000000\npi_approx = approximate_pi_monte_carlo(num_points)\nprint(f\"Approximation of Pi: {pi_approx}\")\nprint(f\"Error: {abs(pi_approx - math.pi)}\")\n```\n\n### Explanation\n\n1. **Leibniz Method**:\n   - **Code**: The function `approximate_pi_leibniz` calculates the sum of the series up to `n_terms`, then multiplies by 4 to get Pi.\n   - **Pros**: Systematic convergence, easier to implement.\n   - **Cons**: Slow convergence, requiring many terms for accuracy.\n\n2. **Monte Carlo Method**:\n   - **Code**: The function `approximate_pi_monte_carlo` generates random points and checks their position relative to a unit circle to estimate Pi.\n   - **Pros**: Parallelizable and probabilistic, providing a different approach to approximation.\n   - **Cons**: Computationally intensive for high precision, less accurate with fewer points.\n\nBoth methods provide an approximation of Pi, with the Leibniz method being more precise for a given number of computations, while the Monte Carlo method offers a simulation-based approach."
        },
        "finish_reason":"stop",
        "logprobs":null
    }],
    "usage":{
        "prompt_tokens":14,
        "completion_tokens":2605,
        "total_tokens":2619
    }
}
```
