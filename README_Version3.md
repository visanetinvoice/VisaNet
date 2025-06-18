## 🚀 VisaNet Python-Based Dispatcher

This project enables direct VisaNet invoice dispatching with automated UUID and timestamp injection, JSON schema validation, and simple containerization.

### Usage

1. **Edit** `moa_payload_template.json` as needed.
2. **Validate and dispatch**:
   ```bash
   python automation/visanet_dispatcher.py
   ```

3. **Dockerize**:
   ```bash
   docker build -t visanet-dispatcher .
   docker run visanet-dispatcher
   ```

### Files

- `automation/visanet_dispatcher.py` — Main dispatcher logic (UUID, timestamp, schema validation, dispatch)
- `schema/moa_payload_schema.json` — JSON schema for payload validation
- `Dockerfile` — Easy containerization and deployment

### Copilot Tips

- Use inline comments like `# Add additional payload logic` for Copilot-powered expansion.
- Extend schema and payload as your business needs evolve.