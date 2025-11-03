const main = async () => {

    const SecureUpdateContractFactory = await hre.ethers.getContractFactory("SecureUpdate");
    const SecureUpdate = await SecureUpdateContractFactory.deploy();
    await SecureUpdate.deployed();
    console.log("Greeter Contract deployed to: ", SecureUpdate.address);

  };
  
  const runMain = async () => {
    try {
      
      await main();
      process.exit(0);
    } catch (error) {
      
      console.log(error);
      process.exit(1);
    }
  };
  
  // Run main
  runMain();