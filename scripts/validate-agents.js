#!/usr/bin/env node

/**
 * RN Agents Framework - Agent Validator
 * Validates that all agents are properly configured
 */

const fs = require('fs');
const path = require('path');

const AGENTS_DIR = path.join(__dirname, '..', 'agents');
const REQUIRED_AGENTS = [
  'orchestrator',
  'product-manager',
  'solution-architect',
  'mobile-architect',
  'backend-architect',
  'data-engineer',
  'native-modules-engineer',
  'performance-optimizer',
  'eas-specialist',
  'offline-architect',
  'security-guardian',
  'test-engineer',
  'qa-lead',
  'observability-engineer',
  'release-manager',
  'ai-integration-engineer',
  'code-reviewer',
  'documentation-engineer',
];

console.log('🔍 Validating RN Agents Framework...\n');

let errors = 0;
let warnings = 0;

// Check if agents directory exists
if (!fs.existsSync(AGENTS_DIR)) {
  console.error('❌ Error: agents/ directory not found');
  process.exit(1);
}

// Check each required agent
REQUIRED_AGENTS.forEach((agentName) => {
  const agentFile = path.join(AGENTS_DIR, `${agentName}.md`);
  
  if (!fs.existsSync(agentFile)) {
    console.error(`❌ Missing agent: ${agentName}.md`);
    errors++;
    return;
  }

  // Read and validate agent content
  const content = fs.readFileSync(agentFile, 'utf-8');
  
  // Check for frontmatter
  if (!content.startsWith('---')) {
    console.warn(`⚠️  ${agentName}.md: Missing frontmatter`);
    warnings++;
  }

  // Check for required fields in frontmatter
  if (!content.includes('name:')) {
    console.warn(`⚠️  ${agentName}.md: Missing 'name' field`);
    warnings++;
  }

  if (!content.includes('description:')) {
    console.warn(`⚠️  ${agentName}.md: Missing 'description' field`);
    warnings++;
  }

  console.log(`✅ ${agentName}.md`);
});

// Check core context files
const coreFiles = [
  '_framework-context.md',
  '_shared-solid-principles.md',
  '_shared-data-modeling.md',
  '_shared-workflows.md',
  '_conflict-resolution.md',
];

const coreDir = path.join(__dirname, '..', '_core');
if (!fs.existsSync(coreDir)) {
  console.error('\n❌ Error: _core/ directory not found');
  errors++;
} else {
  console.log('\n📋 Checking core context files...');
  coreFiles.forEach((file) => {
    const filePath = path.join(coreDir, file);
    if (fs.existsSync(filePath)) {
      console.log(`✅ ${file}`);
    } else {
      console.error(`❌ Missing: ${file}`);
      errors++;
    }
  });
}

// Summary
console.log('\n' + '='.repeat(50));
if (errors === 0 && warnings === 0) {
  console.log('✅ All validations passed!');
  console.log(`📊 ${REQUIRED_AGENTS.length} agents validated`);
  process.exit(0);
} else {
  if (errors > 0) {
    console.error(`❌ ${errors} error(s) found`);
  }
  if (warnings > 0) {
    console.warn(`⚠️  ${warnings} warning(s) found`);
  }
  process.exit(errors > 0 ? 1 : 0);
}
