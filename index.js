const ethers = require("ethers");
const axios = require("axios");

const BASE_URL = `https://auth.watches.disciplina.io/api`;

/*eslint new-cap: ["error", { "properties": false }]*/
const http = new axios.create({
  baseURL: BASE_URL,
  withCredentials: true,
  headers: {
    "Content-Type": "application/json",
    "tmp-csrf": "tmp-csrf",
    mode: "no-cors",
  },
});

class AAAService {
  constructor(httpInstance, accessToken = null) {
    this.httpService = httpInstance;
    this.accessToken = accessToken;
  }

  findUser(publicAddress) {
    return this.httpService
      .get("/users", {
        params: { publicAddress },
      })
      .then((res) => res.data);
  }

  createUser(publicAddress) {
    return this.httpService
      .post("/users", { publicAddress })
      .then((res) => res.data);
  }

  getCurrentUser() {
    const accessToken = localStorage.getItem("accessToken");
    if (!accessToken) {
      throw Error("Attempt to access authenticated route before login");
    }

    return this.httpService
      .get("/users/current", {
        headers: { Authorization: `Bearer ${accessToken}` },
      })
      .then((res) => res.data);
  }

  setUsername(username) {
    const accessToken = localStorage.getItem("accessToken");
    if (!accessToken) {
      throw Error("Attempt to access authenticated route before login");
    }

    return this.httpService
      .patch(
        "/users/current",
        { username },
        { headers: { Authorization: `Bearer ${accessToken}` } }
      )
      .then((res) => res.data);
  }

  login(publicAddress, signature) {
    return this.httpService
      .post("/auth", { publicAddress, signature })
      .then((res) => res.data);
  }
}

async function main() {
  const provider = new ethers.EtherscanProvider(
    "sepolia",
    "VRK6B42QFCRFH3M3UPHBTA2Y48ZV2H188C"
  );

  const wallet = ethers.Wallet.createRandom(provider);

  const authService = new AAAService(http);

  console.log(provider);
  console.log(wallet);
  console.log(await authService.findUser(wallet.address));
}

main();
