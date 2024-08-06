function main(args) {
  const name = args && args.name || 'World';
  return { greeting: `Hello, ${name}!`};
}
